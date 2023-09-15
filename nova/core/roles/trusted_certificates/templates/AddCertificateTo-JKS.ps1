$ErrorActionPreference = 'Stop'

$JavaKeytools = Get-ChildItem "C:\Program Files\Java" -Recurse  | Where-object Name -eq keytool.exe | Select-Object -ExpandProperty FullName
$CertFilePath = "{{ post_scripts_folder_on_target }}/{{ item.name }}.crt"

#----------End of variables, start of script----------#

foreach ($JavaKeytool in $JavaKeytools) {

    $CertFile = & $JavaKeytool -v -printcert -file $CertFilePath | findstr.exe "Owner:"
    $CertSubject = $CertFile.Trim("Owner: CN=")
    $Alias = $CertSubject.Replace(" ","_")

    & $JavaKeytool -importcert -alias $Alias -cacerts -file $CertFilePath -trustcacerts -noprompt -storepass changeit
    & $JavaKeytool -cacerts -storepass changeit -list -alias $Alias

}
