function Get-CurrentUserContext
{
  [CmdletBinding()]
  [Alias('whom')]
  Param
  (
    [Parameter(ValueFromPipeline)]
    [string[]]$ComputerName
  )

  Begin
  {
  }
    
  Process
  {
    $userName = $env:USERNAME
    $isAdmin =  ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    $hostName = $env:COMPUTERNAME        
    $isDomain = (Get-CimInstance -ClassName Win32_ComputerSystem).Domain
    $isWorkgroup = (Get-CimInstance -ClassName Win32_ComputerSystem).Workgroup
    $FQDN=(Get-WmiObject win32_computersystem).DNSHostName+"."+(Get-WmiObject win32_computersystem).Domain
       
    $data = [ordered]@{
      User        = $userName
      IsAdmin     = $isAdmin
      Host        = $hostName
      Workgroup   = $isWorkgroup
      Domain      = $isDomain
      FQDN        = $FQDN
    }

    $out = New-Object -TypeName PSCustomObject -Property $data
  }
  End
  {
    if ((Get-CimInstance -ClassName Win32_ComputerSystem).PartOfDomain -eq $true)
    {
      $out | Select-Object -Property User, IsAdmin, Host, Domain, FQDN | Format-List
    }
    else
    {
      $out | Select-Object -Property User, IsAdmin, Host, Workgroup | Format-List
    }
  }
}
Get-CurrentUserContext