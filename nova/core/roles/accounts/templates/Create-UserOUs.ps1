
$ErrorActionPreference = 'Stop'

function New-OrganizationalUnitFromDN
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [string]$DN
    )

    # A regex to split the DN, taking escaped commas into account
    $DNRegex = '(?<![\\]),'

    # Array to hold each component
    [String[]]$MissingOUs = @()

    # We'll need to traverse the path, level by level, let's figure out the number of possible levels 
    $Depth = ($DN -split $DNRegex).Count

    # Step through each possible parent OU
    for($i = 1;$i -le $Depth;$i++)
    {
        $NextOU = ($DN -split $DNRegex,$i)[-1]
        if($NextOU.IndexOf("OU=") -ne 0 -or [ADSI]::Exists("LDAP://$NextOU"))
        {
            break
        }
        else
        {
            # OU does not exist, remember this for later
            $MissingOUs += $NextOU
        }
    }

    # Reverse the order of missing OUs, we want to create the top-most needed level first
    [array]::Reverse($MissingOUs)

    # Prepare common parameters to be passed to New-ADOrganizationalUnit
    $PSBoundParameters.Remove('DN')

    # Now create the missing part of the tree, including the desired OU
    foreach($OU in $MissingOUs)
    {
        $newOUName = (($OU -split $DNRegex,2)[0] -split "=")[1]
        $newOUPath = ($OU -split $DNRegex,2)[1]

        New-ADOrganizationalUnit -Name $newOUName -Path $newOUPath @PSBoundParameters -ProtectedFromAccidentalDeletion {{ ou_protected_from_accidental_deletion_state | default('$false') }}
    }
}

{% for organizational_unit in domain_groups %}
{% if organizational_unit.ou is defined %}

New-OrganizationalUnitFromDN -DN "{{ organizational_unit.ou }}"

{% endif %}
{% endfor %}

{% for organizational_unit in accounts %}
{% if organizational_unit.ou is defined %}

New-OrganizationalUnitFromDN -DN "{{ organizational_unit.ou }}"

{% endif %}
{% endfor %}