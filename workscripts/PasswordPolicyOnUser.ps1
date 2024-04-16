
$username = "employee1"
$domain = "domain"

Get-ADUserResultantPasswordPolicy -Identity $username -Server $domain

Get-ADDefaultDomainPasswordPolicy

$PasswordPolicyHash = @{
    Name                              = "Test Password Policy"
    $Precedence                       = 1
    ComplexityEnabled                 = $true
    MinPasswordLength                 = 12
    LockoutThreshold                  = 10
    Server                            = $domain
    ProtectedFromAccidentalDeletion   = $true
    ReversReversibleEncryptionEnabled = $false
}

# to reference a hashtable you need to use the '@' symbol to call the property values

# creates a new password policy with the following settings
New-ADFineGrainedPasswordPolicy @PasswordPolicyHash

# we need to change the Name property to Identity instead for the Set-ADFineGrainedPasswordPolicy cmdlet
$PasswordPolicyHash = @{
    Identity                          = "Test Password Policy"
    $Precedence                       = 1
    ComplexityEnabled                 = $true
    MinPasswordLength                 = 12
    LockoutThreshold                  = 10
    Server                            = $domain
    ProtectedFromAccidentalDeletion   = $true
    ReversReversibleEncryptionEnabled = $false
}

# the Set-ADFineGrainedPasswordPolicy cmdlet allows you to update/modify an existing password policy
Set-ADFineGrainedPasswordPolicy @PasswordPolicyHash

# applies the password policy to an AD user which is 'brylle.purificacion'
Add-ADFineGrainedPasswordPolicySubject - Identity "Test Password Policy" -Subjects (Get-ADUser -Identity brylle.purificacion -Server $domain | Select-Object DistinguishedName)

# verifies the actual password policy and to which subjects it is applied to
Get-ADFineGrainedPasswordPolicySubject -Identity "Test Password Policy"


# applies the password policy to the AD group called Marketing
Add-ADFineGrainedPasswordPolicySubject - Identity "Test Password Policy" -Subjects (Get-ADGroup -Identity Marketing -Server $domain | Select-Object DistinguishedName)

# verifies the members of that ad group called Marketing, you will have to use the Recursive switch parameter
Get-ADGroupMember -Identity Marketing -Server $domain -Recursive