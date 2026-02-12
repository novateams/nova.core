$ErrorActionPreference = 'Stop'

{% for ou in accounts_ou_list %}

$Name = "{{ ou.path | regex_replace('^OU=([^,]+).*$', '\\1') }}"
$Path = "{{ ou.path | regex_replace('^OU=[^,]+,(.*)$', '\\1') }}"
$DistinguishedName = "{{ ou.path }}"
$ProtectedFromAccidentalDeletion = ${{ accounts_protect_ou_from_accidental_deletion }}
if($null -eq (Get-ADOrganizationalUnit -Filter * | Where-Object DistinguishedName -Like $DistinguishedName | Select-Object -ExpandProperty DistinguishedName)){
    New-ADOrganizationalUnit -Name $Name -Path $Path -ProtectedFromAccidentalDeletion $ProtectedFromAccidentalDeletion
}

{% endfor %}