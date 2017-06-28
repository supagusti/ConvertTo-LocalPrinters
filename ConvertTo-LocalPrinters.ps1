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
 
     [CmdletBinding(SupportsShouldProcess=$True,ConfirmImpact='Medium')]
     Param
     (

         # Computername
         [Parameter(Mandatory=$false,
                    ValueFromPipelineByPropertyName=$true,
                    Position=1)]
         $Computername


     )

    if ($Computername) 
    {
        $printers = get-printer -ComputerName $Computername
    }
    else
    {
        $printers = get-printer
    }

    foreach ($printer in $printers)
    {
        if ($printer.type -eq "Connection")
        {
            Write-Verbose ("Detected" + $printer.Name + "at share" + $printer.ComputerName + "\"+ $printer.ShareName)
            $printerPort=Get-PrinterPort -Name $printer.PortName -ComputerName $printer.ComputerName
            Write-Verbose ("PortName:" + $printerPort.Name + "->" + $printerPort.PrinterHostAddress + ":" + $printerPort.PortNumber)
            $printerDriver = Get-PrinterDriver -Name $printer.DriverName
            Write-Verbose ("using driver:" + $printerDriver.Name)
            $printerPortName="IP_"+$printerPort.Name

            if ($PSCmdlet.ShouldProcess($printerPortName,"add port")) {
                Write-Verbose ("adding local Printer Port:" + $printerPortName)
                Add-PrinterPort -Name $printerPortName -PrinterHostAddress $printerPort.PrinterHostAddress
            }
            
            if ($PSCmdlet.ShouldProcess($printer.ShareName,"install printer")) {
                Write-Host ("installing local Printer --> Name: " + $printer.ShareName + " with driver: " + $printerDriver.Name + " on port 1" + $printerPortName)
                Add-Printer -name $printer.ShareName -drivername $printerDriver.Name -port $printerPortName
            }
            Write-Verbose ("-----------------------------------------------------------------------------------------------------------------------------------------------------")
        }
        
    }

}