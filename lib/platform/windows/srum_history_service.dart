import 'dart:convert';

import '../../core/services/process_runner.dart';

/// What one program used in the period, from the System Resource Usage Monitor.
class SrumAppUsage {
  const SrumAppUsage({
    required this.name,
    required this.path,
    required this.bytesSent,
    required this.bytesReceived,
    required this.foregroundCycles,
    required this.backgroundCycles,
    required this.bytesRead,
    required this.bytesWritten,
  });

  /// File or service name; empty for traffic Windows does not attribute to a program.
  final String name;
  final String path;
  final int bytesSent;
  final int bytesReceived;
  final int foregroundCycles;
  final int backgroundCycles;
  final int bytesRead;
  final int bytesWritten;

  int get networkBytes => bytesSent + bytesReceived;
  int get cycles => foregroundCycles + backgroundCycles;
  bool get attributed => name.isNotEmpty;
}

class SrumHistory {
  const SrumHistory({
    required this.serviceStatus,
    required this.serviceStartType,
    required this.databaseWrite,
    required this.firstRecord,
    required this.lastRecord,
    required this.apps,
  });

  /// Diagnostic Policy Service, which runs SRUM: "Running", "Stopped" or empty when missing.
  final String serviceStatus;
  final String serviceStartType;
  final DateTime? databaseWrite;
  final DateTime? firstRecord;
  final DateTime? lastRecord;
  final List<SrumAppUsage> apps;

  bool get collecting => serviceStatus == 'Running';
  int get totalCycles => apps.fold(0, (sum, app) => sum + app.cycles);

  static const days = 30;

  /// Validates the helper output and merges rows of the same program (SRUM stores paths in more than one case).
  static SrumHistory fromJson(Map<String, Object?> json) {
    DateTime? time(String key) {
      final value = json[key];
      if (value == null || value == '') return null;
      if (value is! String) throw const FormatException('Invalid SRUM time.');
      return DateTime.parse(value).toUtc();
    }

    if (json['serviceStatus'] is! String ||
        json['serviceStartType'] is! String ||
        json['apps'] is! List) {
      throw const FormatException('Invalid SRUM history response.');
    }
    final merged = <String, List<int>>{};
    final paths = <String, String>{};
    const fields = <String>[
      'BytesSent',
      'BytesReceived',
      'ForegroundCycles',
      'BackgroundCycles',
      'BytesRead',
      'BytesWritten',
    ];
    for (final row in json['apps']! as List) {
      if (row is! Map || row['Name'] is! String) {
        throw const FormatException('Invalid SRUM app row.');
      }
      final values = <int>[];
      for (final field in fields) {
        final value = row[field];
        if (value is! int || value < 0) {
          throw const FormatException('Invalid SRUM counter.');
        }
        values.add(value);
      }
      final path = row['Name'] as String;
      // "#<id>" is an id SRUM keeps no name for: traffic Windows itself does not attribute.
      final key = path.startsWith('#') ? '' : path.toLowerCase();
      paths.putIfAbsent(key, () => key.isEmpty ? '' : path);
      final total = merged.putIfAbsent(
        key,
        () => List<int>.filled(fields.length, 0),
      );
      for (var index = 0; index < fields.length; index++) {
        total[index] += values[index];
      }
    }
    return SrumHistory(
      serviceStatus: json['serviceStatus']! as String,
      serviceStartType: json['serviceStartType']! as String,
      databaseWrite: time('databaseWrite'),
      firstRecord: time('firstRecord'),
      lastRecord: time('lastRecord'),
      apps: List.unmodifiable(<SrumAppUsage>[
        for (final MapEntry(:key, value: totals) in merged.entries)
          SrumAppUsage(
            name: displayName(paths[key]!),
            path: paths[key]!,
            bytesSent: totals[0],
            bytesReceived: totals[1],
            foregroundCycles: totals[2],
            backgroundCycles: totals[3],
            bytesRead: totals[4],
            bytesWritten: totals[5],
          ),
      ]),
    );
  }

  /// `\Device\HarddiskVolume3\…\chrome.exe` → `chrome.exe`; `svchost.exe [Group]` and `System` stay as they are.
  static String displayName(String path) {
    final service = RegExp(r'^(.*?)(\s\[[^\]]*\])$').firstMatch(path);
    final file = service?.group(1) ?? path;
    final name = file
        .split('\\')
        .lastWhere((part) => part.isNotEmpty, orElse: () => file);
    return '$name${service?.group(2) ?? ''}';
  }
}

/// Reads the last [SrumHistory.days] days of SRUM. Needs administrator rights: it runs inside the elevated helper.
/// The live database is locked, so it reads a shadow (VSS) copy in a temporary folder and deletes it afterwards;
/// a copy left in a dirty state is repaired (the copy only) and read again. Nothing in Windows is changed.
class WindowsSrumHistoryService {
  const WindowsSrumHistoryService({required this.processRunner});

  final ProcessRunner processRunner;

  Future<Map<String, Object?>> collect() async {
    final decoded = jsonDecode(
      await processRunner.runPowerShellForOutput(script),
    );
    if (decoded is! Map) {
      throw const FormatException('Invalid SRUM history response.');
    }
    return Map<String, Object?>.from(decoded);
  }

  static const script =
      r'''
$ErrorActionPreference='Stop'
$sru=Join-Path $env:windir 'System32\sru\SRUDB.dat'
$service=Get-Service -Name DPS -ErrorAction SilentlyContinue
$result=[ordered]@{serviceStatus=[string]$service.Status;serviceStartType=[string]$service.StartType;databaseWrite='';firstRecord='';lastRecord='';apps=@()}
if(Test-Path -LiteralPath $sru){
$result.databaseWrite=(Get-Item -LiteralPath $sru).LastWriteTimeUtc.ToString('o')
$esentutl=Join-Path $env:windir 'System32\esentutl.exe'
$work=Join-Path $env:windir ('Temp\zaptweaks-srum-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $work | Out-Null
try{
$copy=Join-Path $work 'SRUDB.dat'
$null=& $esentutl /y $sru /vss /d $copy
if($LASTEXITCODE -ne 0){throw "Copying the SRUM database failed (esentutl $LASTEXITCODE)."}
Add-Type -TypeDefinition @'
''' +
      _reader +
      r'''
'@
try{$data=[ZapSrum]::Read($copy,30)}catch{
$null=$null | & $esentutl /p $copy /o
if($LASTEXITCODE -ne 0){throw "Repairing the SRUM copy failed (esentutl $LASTEXITCODE)."}
$data=[ZapSrum]::Read($copy,30)}
$result.firstRecord=$data.first;$result.lastRecord=$data.last;$result.apps=@($data.apps)
}finally{Remove-Item -LiteralPath $work -Recurse -Force -ErrorAction SilentlyContinue}
}
$result | ConvertTo-Json -Compress -Depth 4
''';

  // ESE (esent.dll) reader: SruDbIdMapTable names the ids, the network and application resource tables hold the usage.
  static const _reader = r'''
using System;using System.Collections.Generic;using System.Runtime.InteropServices;using System.Text;
public static class ZapSrum{
[StructLayout(LayoutKind.Sequential)]struct Col{public uint cb,id,type;public ushort a,b,c,d;public uint max,bits;}
[DllImport("esent.dll",CharSet=CharSet.Unicode)]static extern int JetGetDatabaseFileInfoW(string db,out int r,int cb,int level);
[DllImport("esent.dll",CharSet=CharSet.Unicode)]static extern int JetCreateInstanceW(out IntPtr i,string n);
[DllImport("esent.dll",CharSet=CharSet.Unicode)]static extern int JetSetSystemParameterW(ref IntPtr i,IntPtr s,int p,IntPtr v,string t);
[DllImport("esent.dll",CharSet=CharSet.Unicode)]static extern int JetSetSystemParameterW(IntPtr i,IntPtr s,int p,IntPtr v,string t);
[DllImport("esent.dll")]static extern int JetInit(ref IntPtr i);
[DllImport("esent.dll")]static extern int JetTerm(IntPtr i);
[DllImport("esent.dll",CharSet=CharSet.Unicode)]static extern int JetBeginSessionW(IntPtr i,out IntPtr s,string u,string p);
[DllImport("esent.dll")]static extern int JetEndSession(IntPtr s,uint g);
[DllImport("esent.dll",CharSet=CharSet.Unicode)]static extern int JetAttachDatabaseW(IntPtr s,string f,uint g);
[DllImport("esent.dll",CharSet=CharSet.Unicode)]static extern int JetOpenDatabaseW(IntPtr s,string f,string c,out uint d,uint g);
[DllImport("esent.dll",CharSet=CharSet.Unicode)]static extern int JetOpenTableW(IntPtr s,uint d,string t,IntPtr p,uint cb,uint g,out IntPtr id);
[DllImport("esent.dll")]static extern int JetCloseTable(IntPtr s,IntPtr t);
[DllImport("esent.dll",CharSet=CharSet.Unicode)]static extern int JetGetTableColumnInfoW(IntPtr s,IntPtr t,string c,ref Col d,uint cb,uint l);
[DllImport("esent.dll")]static extern int JetMove(IntPtr s,IntPtr t,int r,uint g);
[DllImport("esent.dll")]static extern int JetRetrieveColumn(IntPtr s,IntPtr t,uint c,byte[] d,uint cb,out uint a,uint g,IntPtr i);
static void Ok(int e,string w){if(e<0)throw new InvalidOperationException(w+": ESE error "+e);}
class T:IDisposable{IntPtr s;public IntPtr id;public bool ok;Dictionary<string,uint> cols=new Dictionary<string,uint>();
public T(IntPtr s,uint d,string n){this.s=s;ok=JetOpenTableW(s,d,n,IntPtr.Zero,0,4,out id)>=0;}
public byte[] B(string n){uint c;if(!cols.TryGetValue(n,out c)){var d=new Col();d.cb=(uint)Marshal.SizeOf(typeof(Col));Ok(JetGetTableColumnInfoW(s,id,n,ref d,d.cb,0),n);cols[n]=c=d.id;}
var b=new byte[256];uint a;int e=JetRetrieveColumn(s,id,c,b,(uint)b.Length,out a,0,IntPtr.Zero);if(e==1004)return null;
if(e==1006){b=new byte[a];e=JetRetrieveColumn(s,id,c,b,a,out a,0,IntPtr.Zero);}Ok(e,n);Array.Resize(ref b,(int)a);return b;}
public long N(string n){var b=B(n);if(b==null)return 0;switch(b.Length){case 1:return b[0];case 2:return BitConverter.ToInt16(b,0);case 4:return BitConverter.ToInt32(b,0);case 8:return BitConverter.ToInt64(b,0);}return 0;}
public DateTime D(string n){var b=B(n);return b==null||b.Length!=8?DateTime.MinValue:DateTime.FromOADate(BitConverter.ToDouble(b,0));}
public bool First(){return JetMove(s,id,int.MinValue,0)>=0;}public bool Next(){return JetMove(s,id,1,0)>=0;}
public void Dispose(){if(ok)JetCloseTable(s,id);}}
public class App{public string Name;public long BytesSent,BytesReceived,ForegroundCycles,BackgroundCycles,BytesRead,BytesWritten;}
public class Result{public string first="",last="";public List<App> apps=new List<App>();}
public static Result Read(string db,int days){int page;Ok(JetGetDatabaseFileInfoW(db,out page,4,17),"Page size");
JetSetSystemParameterW(IntPtr.Zero,IntPtr.Zero,64,(IntPtr)page,null);IntPtr inst;Ok(JetCreateInstanceW(out inst,"ZapSrum"),"Instance");
var dir=System.IO.Path.GetDirectoryName(db)+"\\";JetSetSystemParameterW(ref inst,IntPtr.Zero,34,IntPtr.Zero,"Off");
foreach(var p in new[]{0,1,2})JetSetSystemParameterW(ref inst,IntPtr.Zero,p,IntPtr.Zero,dir);
Ok(JetInit(ref inst),"Init");IntPtr s=IntPtr.Zero;
try{Ok(JetBeginSessionW(inst,out s,"",""),"Session");Ok(JetAttachDatabaseW(s,db,1),"Attach");uint d;Ok(JetOpenDatabaseW(s,db,null,out d,1),"Open");
var names=new Dictionary<long,string>();
using(var m=new T(s,d,"SruDbIdMapTable")){if(!m.ok)throw new InvalidOperationException("SruDbIdMapTable missing");
if(m.First())do{if(m.N("IdType")==3)continue;var b=m.B("IdBlob");if(b!=null)names[m.N("IdIndex")]=Encoding.Unicode.GetString(b).TrimEnd('\0');}while(m.Next());}
var since=DateTime.UtcNow.AddDays(-days);var apps=new Dictionary<long,App>();DateTime first=DateTime.MaxValue,last=DateTime.MinValue;
Func<long,App> A=k=>{App x;if(!apps.TryGetValue(k,out x))apps[k]=x=new App{Name=names.ContainsKey(k)?names[k]:"#"+k};return x;};
using(var t=new T(s,d,"{973F5D5C-1D90-4944-BE8E-24B94231A174}"))if(t.ok&&t.First())do{var w=t.D("TimeStamp");if(w>last)last=w;if(w<since)continue;if(w<first)first=w;
var x=A(t.N("AppId"));x.BytesSent+=t.N("BytesSent");x.BytesReceived+=t.N("BytesRecvd");}while(t.Next());
using(var t=new T(s,d,"{D10CA2FE-6FCF-4F6D-848E-B2E99266FA89}"))if(t.ok&&t.First())do{var w=t.D("TimeStamp");if(w>last)last=w;if(w<since)continue;if(w<first)first=w;
var x=A(t.N("AppId"));x.ForegroundCycles+=t.N("ForegroundCycleTime");x.BackgroundCycles+=t.N("BackgroundCycleTime");
x.BytesRead+=t.N("ForegroundBytesRead")+t.N("BackgroundBytesRead");x.BytesWritten+=t.N("ForegroundBytesWritten")+t.N("BackgroundBytesWritten");}while(t.Next());
var r=new Result();r.apps.AddRange(apps.Values);
r.apps.Sort((a,b)=>(b.BytesSent+b.BytesReceived+(b.ForegroundCycles+b.BackgroundCycles)/1000).CompareTo(a.BytesSent+a.BytesReceived+(a.ForegroundCycles+a.BackgroundCycles)/1000));
if(r.apps.Count>200)r.apps.RemoveRange(200,r.apps.Count-200);
if(first!=DateTime.MaxValue)r.first=DateTime.SpecifyKind(first,DateTimeKind.Utc).ToString("o");if(last!=DateTime.MinValue)r.last=DateTime.SpecifyKind(last,DateTimeKind.Utc).ToString("o");return r;}
finally{if(s!=IntPtr.Zero)JetEndSession(s,0);JetTerm(inst);}}}
''';
}
