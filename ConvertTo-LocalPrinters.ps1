 <#
 .Synopsis
    converts installed network printers to local printers with a tcp port
 .DESCRIPTION
    With this advanded function it's possible to automate the conversion of server based network printers to local ip port based network printers.
    (no parameters)
    
 .EXAMPLE
    convertTo-LocalPrinters

 #>

 function ConvertTo-LocalPrinters
 {
     [CmdletBinding()]
     [Alias()]
     [OutputType([int])]
     Param
     (

         # None
         [Parameter(Mandatory=$false,
                    ValueFromPipelineByPropertyName=$true,
                    Position=1)]
         $none


     )


    $printers = get-printer

    foreach ($printer in $printers)
    {
        if ($printer.type -eq "Connection")
        {
            Write-Host "Detected"$printer.Name"at share"$printer.ComputerName"\"$printer.ShareName
            $printerPort=Get-PrinterPort -Name $printer.PortName -ComputerName $printer.ComputerName
            Write-Host "PortName:"$printerPort.Name"->"$printerPort.PrinterHostAddress":"$printerPort.PortNumber
            $printerDriver = Get-PrinterDriver -Name $printer.DriverName
            Write-Host "using driver:"$printerDriver.Name
            $printerPortName="IP_"+$printerPort.Name
            Write-Host "adding local Printer Port: $printerPortName"
            Add-PrinterPort -Name $printerPortName -PrinterHostAddress $printerPort.PrinterHostAddress
            Write-Host "installing local Printer --> Name:"$printer.ShareName"with driver:"$printerDriver.Name
            Add-Printer -name $printer.ShareName -drivername $printerDriver.Name -port $printerPortName
            Write-Host "-----------------------------------------------------------------------------------------------------------------------------------------------------"
        }
        
    }

}