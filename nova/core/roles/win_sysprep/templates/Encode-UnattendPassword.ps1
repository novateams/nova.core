###
$ErrorActionPreference = 'Stop'

$AdministratorPassword = "{{ post_sysprep_administrator_password }}"

#------------------------------------End of variables, Start of Script----------------------------------------------------------------------------------------------------------

$EncodedAdministratorPassword = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes(('{0}AdministratorPassword' -f $AdministratorPassword)))
$EncodedAutoLogonPassword = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes(('{0}Password' -f $AdministratorPassword)))

$EncodedAdministratorPassword
$EncodedAutoLogonPassword
