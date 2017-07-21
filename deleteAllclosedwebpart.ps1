[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint.Publishing")
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint") > $null

#For SharePoint 2013
function global:Get-SPSite($url)
{
    return new-Object Microsoft.SharePoint.SPSite($url)
}
 
function ListWebParts($web) 
{
    if ([Microsoft.SharePoint.Publishing.PublishingWeb]::IsPublishingWeb($web))
    {
        $webPublish = [Microsoft.SharePoint.Publishing.PublishingWeb]::GetPublishingWeb($web)
        $pages = $webPublish.GetPublishingPages()
 
        foreach($page in $pages)
        {
            $manager = $web.GetLimitedWebPartManager($page.Url, [System.Web.UI.WebControls.WebParts.PersonalizationScope]::Shared)
            $webCollection = $manager.WebParts
         
            if($webCollection.Count -ne 0)
            {
                $count=$webCollection.Count
                for($i =0;$i -lt $count; $i++)
                {
                     #If the webpart is closed
                    if ($webCollection[$i].IsClosed -eq $TRUE)
                    { 
                        write-host $web.url"/"$page.url  "||" $webCollection[$i].GetType().Name "||" $webCollection[$i].Title
                        $sw.writeline($web.url + "/" + $page.url + " || " + $webCollection[$i].GetType().Name + " || " +    $webCollection[$i].Title)
                        #check mode
                        $file= $web.GetFile($page.url)
                        if ($mode -eq "delete")
                        {
                            write-host "deleted from" $web.url"/"$page.url  "||" $webCollection[$i].GetType().Name "||" $webCollection[$i].Title
                            $sw.writeline("deleted from " + $web.url + "/" + $page.url + " || " + $webCollection[$i].GetType().Name + " || " +    $webCollection[$i].Title)
                            if ($file.RequiresCheckout -eq $TRUE -and $file.CheckOutStatus -eq "None") { $manager.Web.GetFile($file.UniqueID).CheckOut()}
       
                            $manager.DeleteWebPart($manager.WebParts[$webCollection[$i].ID])
                            
                            if ($file.RequiresCheckout -eq $TRUE -and $file.CheckOutStatus -eq "None") { $manager.Web.GetFile($file.UniqueID).CheckIn("Deleted web part: " + $webCollection[$i].Title  + "By PowerShell" )}
                    
                        }
                       
                    }
                }
            }
        }
    }
}


function LoadSPSite($url, $mod)
{
    #Get SiteURL from Command-Line
    $siteURL = $url #"http://xyz.com" pass site collection url as argument#$args[0]
  
    #Get Mode from Command-Line
    $mode= $mod#"delete" #$args[1]

    #Get all site
    $site = Get-SPSite($siteURL)
    
    foreach($web in $site.allwebs)
    {
        write-output $web.Title
        ListWebParts($web)
    }
    $site.Dispose()
}
 
$sw = [System.IO.StreamWriter] "C:\PSlog.txt"
$sw.writeline("Page URL || Web Part Type || Web Part Title")
$url = $args[0]
#passing mode ('delete', 'report')
$mod = $args[1]
LoadSPSite($url,$mod)
$sw.close()