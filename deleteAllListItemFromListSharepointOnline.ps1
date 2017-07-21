#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
   
#Variables for Processing
$SiteUrl = "https://xyz.com" # site collection URL
$ListName="ListName" #list name
 
$UserName="username"
$Password ="pwd"
  
#Setup Credentials to connect
$Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($UserName,(ConvertTo-SecureString $Password -AsPlainText -Force))
  
#Set up the context
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteUrl)
$Context.Credentials = $credentials
   
#Get the List
$List = $Context.web.Lists.GetByTitle($ListName)

#Caml Query
$query=New-Object Microsoft.SharePoint.Client.CamlQuery  
$query.ViewXml="<View><RowLimit>200</RowLimit></View>"  


do
{
    $started = Get-Date
    #$ListItems = $List.GetItems([Microsoft.SharePoint.Client.CamlQuery]::CreateAllItemsQuery())
    $ListItems = $List.GetItems($query);
    $Context.Load($ListItems)
    $Context.ExecuteQuery()
     
    write-host "Total Number of List Items found:"$ListItems.Count
    if ($ListItems.Count -eq 0) { break }

    for ($i = 0; $i -lt $ListItems.Count; $i++)
    {
       $ListItems[$i].DeleteObject()
    }

    $Context.ExecuteQuery()
    Write-Host "Time elapsed: $((Get-Date) - $started)"
} while ($true)

 Write-Host "All List Items deleted Successfully!"  

 