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
                for($i =0;$i -lt $webCollection.Count; $i++)
                {
 		            if ($webCollection[$i].IsClosed -eq $TRUE)
                    { 
                      	$sw.writeline($web.url + "//" + $page.url + " || " + $webCollection[$i].GetType().Name + " || " +    $webCollection[$i].Title)
		            }
                }
            }
        }
    }
}
 
function LoadSPSite($sl)
{    
    Write-Host "Script continued"
    $siteURL = $sl  #"http://xyz.com" pass site collection url as argument
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
$sl = $args[0]
LoadSPSite($sl)
$sw.close()