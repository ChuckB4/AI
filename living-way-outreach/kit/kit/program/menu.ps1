# ============================================================
#  Living Way UPC Outreach - Main Menu
#  Designed for a non-technical user. Plain language, safe.
# ============================================================

$ErrorActionPreference = "Stop"

# The kit lives wherever Don unzipped it. Figure that out automatically.
$KitRoot  = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$DataRoot = Join-Path $KitRoot "data"
$Backups  = Join-Path $KitRoot "backups"
$Imports  = Join-Path $KitRoot "imports_dropbox"

foreach ($d in @($DataRoot, $Backups, $Imports)) {
    if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d -Force | Out-Null }
}

$Contacts   = Join-Path $DataRoot "contacts.csv"
$Members    = Join-Path $DataRoot "church_members.csv"
$Volunteers = Join-Path $DataRoot "volunteer_signups.csv"
$Routes     = Join-Path $DataRoot "saturday_routes.csv"
$Events     = Join-Path $DataRoot "events.csv"
$Campaigns  = Join-Path $DataRoot "campaigns.csv"
$FbPosts    = Join-Path $DataRoot "facebook_posts.csv"
$Pins       = Join-Path $DataRoot "field_pins.csv"

function Next-Id($path, $idField) {
    if (-not (Test-Path $path)) { return 1 }
    $rows = Import-Csv $path
    if (-not $rows -or $rows.Count -eq 0) { return 1 }
    $max = 0
    foreach ($r in $rows) { $n = 0; if ([int]::TryParse($r.$idField, [ref]$n)) { if ($n -gt $max) { $max = $n } } }
    return $max + 1
}

function Pause-Return {
    Write-Host ""
    Write-Host "Press Enter to go back to the menu..." -ForegroundColor DarkGray
    [void](Read-Host)
}

function Backup-File($path) {
    if (Test-Path $path) {
        $name = Split-Path $path -Leaf
        $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
        Copy-Item $path (Join-Path $Backups ($stamp + "_" + $name)) -Force
    }
}

function Count-Csv($path) {
    if (Test-Path $path) { return (Import-Csv $path | Measure-Object).Count } else { return 0 }
}

# ---------- Import a list (member list OR outreach list) ----------
function Import-List($targetFile, $whatItIs) {
    Clear-Host
    Write-Host "===========================================================" -ForegroundColor Cyan
    Write-Host "  IMPORT YOUR $whatItIs" -ForegroundColor Cyan
    Write-Host "===========================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Step 1. Find your list file on this computer."
    Write-Host "          It can be a spreadsheet (.csv or .xlsx)."
    Write-Host ""
    Write-Host "  Step 2. DRAG the file into this window, then press Enter."
    Write-Host "          (Or type the full location of the file.)"
    Write-Host ""
    $raw = Read-Host "  File"
    $file = $raw.Trim().Trim('"')
    if (-not (Test-Path $file)) {
        Write-Host ""
        Write-Host "  I couldn't find that file. Nothing was changed." -ForegroundColor Yellow
        Write-Host "  Tip: just drag the file into the window instead of typing." -ForegroundColor Yellow
        Pause-Return; return
    }

    # Keep an untouched copy of the original (never lose source data)
    $origName = Split-Path $file -Leaf
    $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    Copy-Item $file (Join-Path $Imports ($stamp + "_" + $origName)) -Force

    # Read the file (xlsx via Excel if available, else csv)
    $ext = [System.IO.Path]::GetExtension($file).ToLower()
    $data = $null
    try {
        if ($ext -eq ".csv") {
            $data = Import-Csv $file
        } elseif ($ext -eq ".xlsx") {
            $excel = New-Object -ComObject Excel.Application
            $excel.Visible = $false
            $wb = $excel.Workbooks.Open($file)
            $ws = $wb.Worksheets.Item(1)
            $used = $ws.UsedRange
            $rows = $used.Rows.Count; $cols = $used.Columns.Count
            $headers = @(); for ($c=1; $c -le $cols; $c++) { $headers += [string]$used.Cells.Item(1,$c).Text }
            $data = @()
            for ($r=2; $r -le $rows; $r++) {
                $obj = [ordered]@{}
                for ($c=1; $c -le $cols; $c++) { $obj[$headers[$c-1]] = [string]$used.Cells.Item($r,$c).Text }
                $data += [pscustomobject]$obj
            }
            $wb.Close($false); $excel.Quit()
        } else {
            Write-Host "  That file type isn't supported. Please use .csv or .xlsx." -ForegroundColor Yellow
            Pause-Return; return
        }
    } catch {
        Write-Host "  I had trouble reading that file. Nothing was changed." -ForegroundColor Yellow
        Write-Host "  ($($_.Exception.Message))" -ForegroundColor DarkGray
        Pause-Return; return
    }

    $newCount = ($data | Measure-Object).Count
    Write-Host ""
    Write-Host "  I read $newCount rows from your file." -ForegroundColor Green
    Write-Host "  Columns found: $(( $data | Select-Object -First 1 | Get-Member -MemberType NoteProperty | Select-Object -Expand Name) -join ', ')" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  I will ADD these to your existing list (I never erase what's there)." -ForegroundColor White
    Write-Host "  A backup is saved first automatically." -ForegroundColor White
    Write-Host ""
    $ok = Read-Host "  Type YES to import, or anything else to cancel"
    if ($ok -ne "YES") { Write-Host "  Cancelled. Nothing was changed." -ForegroundColor Yellow; Pause-Return; return }

    Backup-File $targetFile
    if (Test-Path $targetFile) {
        $data | Export-Csv $targetFile -NoTypeInformation -Append
    } else {
        $data | Export-Csv $targetFile -NoTypeInformation
    }
    Write-Host ""
    Write-Host "  DONE. Imported $newCount rows into your $whatItIs." -ForegroundColor Green
    Write-Host "  Original file kept safely in the imports folder." -ForegroundColor Green
    Pause-Return
}

# ---------- Show a summary ----------
function Show-Summary {
    Clear-Host
    Write-Host "===========================================================" -ForegroundColor Cyan
    Write-Host "  WHERE THINGS STAND RIGHT NOW" -ForegroundColor Cyan
    Write-Host "===========================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host ("  Community contacts (people we met): {0}" -f (Count-Csv $Contacts))
    Write-Host ("  Church members on file:            {0}" -f (Count-Csv $Members))
    Write-Host ("  Volunteers signed up:              {0}" -f (Count-Csv $Volunteers))
    Write-Host ""
    if (Test-Path $Contacts) {
        $c = Import-Csv $Contacts
        $withAddr = ($c | Where-Object { $_.MailingAddress -and $_.MailingAddress -ne "" } | Measure-Object).Count
        Write-Host ("  Contacts WITH a confirmed address: {0}" -f $withAddr)
        Write-Host ("  Contacts WITHOUT an address:       {0}" -f (($c | Measure-Object).Count - $withAddr))
        Write-Host ""
        Write-Host "  NOTE: We only visit people who gave us an address and said yes." -ForegroundColor Yellow
    }
    Pause-Return
}

# ---------- Open the data folder ----------
function Open-DataFolder {
    Start-Process explorer.exe $DataRoot
}

# ---------- FIELD MAP & TEAM CHAT (free tools: Google My Maps + group chat) ----------
function FieldMap-Menu {
    while ($true) {
        Clear-Host
        Write-Host "===========================================================" -ForegroundColor Cyan
        Write-Host "  FIELD MAP & TEAM CHAT  (free - works on every phone)" -ForegroundColor Cyan
        Write-Host "===========================================================" -ForegroundColor Cyan
        Write-Host "  Drop map pins for where you served or had good door-knocks," -ForegroundColor White
        Write-Host "  and text your teams live - all with FREE tools, no app to buy." -ForegroundColor White
        Write-Host ""
        $pc = Count-Csv $Pins
        Write-Host ("  Pins recorded in the kit so far: {0}" -f $pc)
        Write-Host ""
        Write-Host "   1   How to set up the free SHARED MAP (one-time, easy)"
        Write-Host "   2   How to set up the free TEAM CHAT (notifications)"
        Write-Host "   3   Record a pin here (served here / good door-knock / revisit)"
        Write-Host "   4   View all my recorded pins"
        Write-Host "   0   Back to main menu"
        Write-Host ""
        $ch = Read-Host "  Your choice"
        switch ($ch) {
            "1" { Show-MapSetup }
            "2" { Show-ChatSetup }
            "3" { Add-Pin }
            "4" { View-Pins }
            "0" { return }
        }
    }
}

function Show-MapSetup {
    Clear-Host
    Write-Host "  SET UP YOUR FREE SHARED MAP  (do this once)" -ForegroundColor Green
    Write-Host "  -------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  We use Google My Maps. It is free and works on any phone."
    Write-Host ""
    Write-Host "   1. On a computer, go to:  www.google.com/mymaps"
    Write-Host "   2. Sign in with the church's free Google account."
    Write-Host "   3. Click 'Create a new map'. Name it (example:"
    Write-Host "      'Living Way Outreach Map')."
    Write-Host "   4. Click 'Share' and set it so your team can view/edit."
    Write-Host "      Copy the share link."
    Write-Host "   5. Text that link to your teams. They open it on their"
    Write-Host "      phones and can drop pins where they serve or have a"
    Write-Host "      good door-knock. Everyone sees the same map."
    Write-Host ""
    Write-Host "  TIP: use different colors - one for 'served here', one for"
    Write-Host "       'good door-knock', one for 'come back later'." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Record those same pins here (option 3) so you keep a" -ForegroundColor White
    Write-Host "  permanent history even if the map changes." -ForegroundColor White
    Pause-Return
}

function Show-ChatSetup {
    Clear-Host
    Write-Host "  SET UP YOUR FREE TEAM CHAT  (do this once)" -ForegroundColor Green
    Write-Host "  -------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  A free group chat gives your phones instant notifications"
    Write-Host "  during an event (example: 'Team 2, head to Oak Street')."
    Write-Host ""
    Write-Host "  EASIEST (works on all phones):"
    Write-Host "   - Use GroupMe (free) or WhatsApp (free), or even a plain"
    Write-Host "     group text message."
    Write-Host "   1. Make one group for ALL volunteers."
    Write-Host "   2. Make a separate group for each team if you like."
    Write-Host "   3. Add each person using the phone numbers from the kit"
    Write-Host "      (Team Messages -> 'Print a phone list for a team')."
    Write-Host ""
    Write-Host "  Now you can send a note to everyone or to just one team," -ForegroundColor White
    Write-Host "  and it pops up on their phones right away." -ForegroundColor White
    Pause-Return
}

function Add-Pin {
    Clear-Host
    Write-Host "  RECORD A PIN  (press Enter to skip any field)" -ForegroundColor Cyan
    Write-Host ""
    $place = Read-Host "  Place or street (example: 400 block of Oak St)"
    if (-not $place) { Write-Host "  A pin needs a place. Nothing added." -ForegroundColor Yellow; Pause-Return; return }
    Write-Host ""
    Write-Host "  What kind of pin?  (type a number)"
    Write-Host "   1  Served here"
    Write-Host "   2  Good door-knock"
    Write-Host "   3  Come back later"
    Write-Host "   4  Other"
    $tp = Read-Host "  Type"
    $pinType = switch ($tp) { "1"{"Served here"} "2"{"Good door-knock"} "3"{"Come back later"} default {"Other"} }
    $what = Read-Host "  What happened (example: served 3 people / nice family, invited them)"
    $team = Read-Host "  Which team (optional)"
    $by   = Read-Host "  Recorded by (optional)"
    $id = Next-Id $Pins "PinID"
    $row = [pscustomobject]@{
        PinID=$id; Date=(Get-Date -Format "yyyy-MM-dd"); PlaceOrStreet=$place; PinType=$pinType;
        WhatHappened=$what; Team=$team; RecordedBy=$by; Notes=""
    }
    Backup-File $Pins
    if (Test-Path $Pins) { $row | Export-Csv $Pins -NoTypeInformation -Append } else { $row | Export-Csv $Pins -NoTypeInformation }
    Write-Host ""
    Write-Host ("  DONE. Pin #{0} recorded: {1} - {2}" -f $id, $pinType, $place) -ForegroundColor Green
    Write-Host "  Remember to also drop it on the shared Google map." -ForegroundColor DarkGray
    Pause-Return
}

function View-Pins {
    Clear-Host
    $ps = @(); if (Test-Path $Pins) { $ps = @(Import-Csv $Pins) }
    if ($ps.Count -eq 0) { Write-Host "  No pins recorded yet." -ForegroundColor Yellow; Pause-Return; return }
    Write-Host "  YOUR RECORDED PINS" -ForegroundColor Green
    Write-Host ""
    foreach ($p in $ps) {
        Write-Host ("   #{0}  [{1}]  {2}" -f $p.PinID, $p.PinType, $p.PlaceOrStreet) -ForegroundColor White
        $extra = @()
        if ($p.WhatHappened) { $extra += $p.WhatHappened }
        if ($p.Date)         { $extra += $p.Date }
        if ($p.Team)         { $extra += ("Team: " + $p.Team) }
        if ($extra.Count -gt 0) { Write-Host ("        " + ($extra -join "  |  ")) -ForegroundColor DarkGray }
    }
    Pause-Return
}

# ---------- EVENTS (reusable: add any event, any time) ----------
function Event-Menu {
    while ($true) {
        Clear-Host
        Write-Host "===========================================================" -ForegroundColor Cyan
        Write-Host "  EVENTS" -ForegroundColor Cyan
        Write-Host "===========================================================" -ForegroundColor Cyan
        Write-Host ""
        $evs = @(); if (Test-Path $Events) { $evs = @(Import-Csv $Events) }
        if ($evs.Count -eq 0) {
            Write-Host "  You have no events yet." -ForegroundColor Yellow
        } else {
            Write-Host ("  You have {0} event(s):" -f $evs.Count)
            Write-Host ""
            foreach ($e in $evs) {
                Write-Host ("   #{0}  {1}" -f $e.EventID, $e.EventName) -ForegroundColor White
                Write-Host ("        {0} at {1}  -  {2}" -f $e.Date, $e.Time, $e.Location) -ForegroundColor DarkGray
            }
        }
        Write-Host ""
        Write-Host "   A   Add a new event"
        Write-Host "   0   Back to main menu"
        Write-Host ""
        $c = Read-Host "  Your choice"
        if ($c -eq "0") { return }
        if ($c -eq "A" -or $c -eq "a") { Add-Event }
    }
}

function Add-Event {
    Clear-Host
    Write-Host "  ADD A NEW EVENT  (press Enter to skip any field)" -ForegroundColor Cyan
    Write-Host ""
    $name = Read-Host "  Event name"
    if (-not $name) { Write-Host "  An event needs a name. Nothing added." -ForegroundColor Yellow; Pause-Return; return }
    $date = Read-Host "  Date (example: Saturday, October 17, 2026)"
    $time = Read-Host "  Time (example: 9:00 AM)"
    $loc  = Read-Host "  Location"
    $desc = Read-Host "  Short description (what is it / who is it for)"
    $aud  = Read-Host "  Audience (example: neighbors, church family)"
    $cp   = Read-Host "  Contact person"
    $id = Next-Id $Events "EventID"
    $row = [pscustomobject]@{
        EventID=$id; EventName=$name; Date=$date; Time=$time; Location=$loc;
        Description=$desc; Audience=$aud; ContactPerson=$cp; Status="Planned";
        CreatedDate=(Get-Date -Format "yyyy-MM-dd"); Notes=""
    }
    Backup-File $Events
    if (Test-Path $Events) { $row | Export-Csv $Events -NoTypeInformation -Append } else { $row | Export-Csv $Events -NoTypeInformation }
    Write-Host ""
    Write-Host ("  DONE. Added event #{0}: {1}" -f $id, $name) -ForegroundColor Green
    Write-Host "  TIP: use the Facebook menu to make a post for this event." -ForegroundColor DarkGray
    Pause-Return
}

# ---------- CAMPAIGNS (reusable: bundle events together) ----------
function Campaign-Menu {
    while ($true) {
        Clear-Host
        Write-Host "===========================================================" -ForegroundColor Cyan
        Write-Host "  CAMPAIGNS  (group one or more events together)" -ForegroundColor Cyan
        Write-Host "===========================================================" -ForegroundColor Cyan
        Write-Host ""
        $cs = @(); if (Test-Path $Campaigns) { $cs = @(Import-Csv $Campaigns) }
        if ($cs.Count -eq 0) { Write-Host "  You have no campaigns yet." -ForegroundColor Yellow }
        else {
            foreach ($c in $cs) {
                Write-Host ("   #{0}  {1}" -f $c.CampaignID, $c.CampaignName) -ForegroundColor White
                Write-Host ("        Events: {0}  |  {1}" -f $c.RelatedEvents, $c.Purpose) -ForegroundColor DarkGray
            }
        }
        Write-Host ""
        Write-Host "   A   Add a new campaign"
        Write-Host "   P   Make a step-by-step PLAYBOOK for a campaign"
        Write-Host "   0   Back to main menu"
        Write-Host ""
        $ch = Read-Host "  Your choice"
        if ($ch -eq "0") { return }
        if ($ch -eq "A" -or $ch -eq "a") { Add-Campaign }
        if ($ch -eq "P" -or $ch -eq "p") { Make-Playbook }
    }
}

function Add-Campaign {
    Clear-Host
    Write-Host "  ADD A NEW CAMPAIGN" -ForegroundColor Cyan
    Write-Host ""
    # Show events so Don can reference them
    $evs = @(); if (Test-Path $Events) { $evs = @(Import-Csv $Events) }
    if ($evs.Count -gt 0) {
        Write-Host "  Your events (you can list their numbers below):" -ForegroundColor DarkGray
        foreach ($e in $evs) { Write-Host ("    #{0} {1}" -f $e.EventID, $e.EventName) -ForegroundColor DarkGray }
        Write-Host ""
    }
    $name = Read-Host "  Campaign name"
    if (-not $name) { Write-Host "  A campaign needs a name. Nothing added." -ForegroundColor Yellow; Pause-Return; return }
    $rel  = Read-Host "  Which event number(s)? (example: 1,2  - or leave blank)"
    $purp = Read-Host "  Purpose (one sentence)"
    $id = Next-Id $Campaigns "CampaignID"
    $row = [pscustomobject]@{
        CampaignID=$id; CampaignName=$name; RelatedEvents=$rel; Purpose=$purp;
        StartDate=""; EndDate=""; Status="Planned"; CreatedDate=(Get-Date -Format "yyyy-MM-dd"); Notes=""
    }
    Backup-File $Campaigns
    if (Test-Path $Campaigns) { $row | Export-Csv $Campaigns -NoTypeInformation -Append } else { $row | Export-Csv $Campaigns -NoTypeInformation }
    Write-Host ""
    Write-Host ("  DONE. Added campaign #{0}: {1}" -f $id, $name) -ForegroundColor Green
    Write-Host "  TIP: use 'Make a step-by-step PLAYBOOK' to get instructions for it." -ForegroundColor DarkGray
    Pause-Return
}

# ---------- CAMPAIGN PLAYBOOK (step-by-step instructions per campaign) ----------
function Make-Playbook {
    Clear-Host
    $cs = @(); if (Test-Path $Campaigns) { $cs = @(Import-Csv $Campaigns) }
    if ($cs.Count -eq 0) { Write-Host "  You have no campaigns yet. Add one first." -ForegroundColor Yellow; Pause-Return; return }
    Write-Host "  Which campaign do you want a playbook for?" -ForegroundColor Cyan
    foreach ($c in $cs) { Write-Host ("    #{0} {1}" -f $c.CampaignID, $c.CampaignName) }
    Write-Host ""
    $pick = Read-Host "  Campaign number"
    $camp = $cs | Where-Object { $_.CampaignID -eq $pick } | Select-Object -First 1
    if (-not $camp) { Write-Host "  Couldn't find that number." -ForegroundColor Yellow; Pause-Return; return }

    # Pull in related events for context (nothing invented - only what Don entered)
    $evs = @(); if (Test-Path $Events) { $evs = @(Import-Csv $Events) }
    $eventLines = ""
    if ($camp.RelatedEvents) {
        $wanted = $camp.RelatedEvents -replace "#","" -split "," | ForEach-Object { $_.Trim() }
        foreach ($e in $evs) {
            if ($wanted -contains [string]$e.EventID) {
                $eventLines += ("   - " + $e.EventName + "  (" + $e.Date + " " + $e.Time + ", " + $e.Location + ")`r`n")
            }
        }
    }
    if (-not $eventLines) { $eventLines = "   (no events linked yet - link events to this campaign for them to appear here)`r`n" }

    $playFolder = Join-Path $KitRoot "playbooks"
    if (-not (Test-Path $playFolder)) { New-Item -ItemType Directory -Path $playFolder -Force | Out-Null }
    $safeName = ($camp.CampaignName -replace '[^A-Za-z0-9 ]','').Trim() -replace '\s+','_'
    $file = Join-Path $playFolder ("Playbook_" + $safeName + ".txt")

    $pb = @"
==============================================================
   CAMPAIGN PLAYBOOK:  $($camp.CampaignName)
   Living Way UPC Outreach
   Created: $(Get-Date -Format "yyyy-MM-dd")
==============================================================

PURPOSE:
   $($camp.Purpose)

EVENTS IN THIS CAMPAIGN:
$eventLines
--------------------------------------------------------------
STEP-BY-STEP INSTRUCTIONS (do these in order)
--------------------------------------------------------------

1. GET LEADERSHIP APPROVAL
   - Show the pastor/leadership this campaign and the messages.
   - Do not send anything until they say yes.

2. RECRUIT VOLUNTEERS
   - Open the program -> Team Messages -> "Write a REMINDER / recruitment text".
   - Choose "Everyone", copy the message, send it from your phone
     (or read the church announcement from the bulletin).
   - As people reply, add them to the volunteer sheet.

3. BUILD YOUR TEAMS
   - Team Messages -> "Assign a volunteer to a team".
   - Pick a CAPTAIN for each team, then add members.
   - Use "View my teams" to check captains and members.

4. PREPARE THE FACEBOOK POST
   - Main menu -> Facebook posts -> "Create a post for one of my events".
   - Review it, copy it, paste it on the Living Way UPC Facebook page.
   - Come back and "Mark a post as POSTED".

5. ASK MEMBERS TO SHARE IT
   - Copy the Facebook post's link from Facebook.
   - Team Messages -> "Write a 'Share our Facebook post' text".
   - Paste the link in, copy the message, send it to your teams.

6. SEND REMINDERS (a few days before, and the morning of)
   - Team Messages -> "Write a REMINDER text".
   - You can send to Everyone, or just one team (type the team name),
     or several teams (type the names separated by commas).

7. SET UP THE FREE MAP AND TEAM CHAT (first time only)
   - Main menu -> Field Map & Team Chat.
   - Follow "How to set up the free SHARED MAP" (Google My Maps).
   - Follow "How to set up the free TEAM CHAT" (group text/GroupMe).
   - Text both links to your teams.

8. DURING THE EVENT
   - Each team captain keeps their members together.
   - Use "Print a phone list for a team" to text a single team fast.
   - Drop pins on the shared map: served here / good door-knock /
     come back later. (Mark PLACES - we do not track people.)
   - Only visit people who gave an address AND said yes to a visit.

9. AFTER THE EVENT
   - Record outcomes and your map pins in the kit.
   - Send thank-you texts (Team Messages -> reminder text, reworded).
   - Reuse this same playbook for the next event.

--------------------------------------------------------------
IMPORTANT SAFETY RULES (always):
   - The program never sends texts or posts by itself. You send them.
   - Never text anyone who said STOP or "do not contact".
   - No home visit without a confirmed address and a yes.
   - Be honest: we are Living Way UPC inviting neighbors.
==============================================================
"@

    Backup-File $file
    $pb | Out-File -FilePath $file -Encoding UTF8
    Write-Host ""
    Write-Host "  DONE. Playbook saved to the 'playbooks' folder:" -ForegroundColor Green
    Write-Host ("    " + $file) -ForegroundColor White
    $open = Read-Host "  Open it now to read/print? (YES/no)"
    if ($open -ne "no") { try { Start-Process notepad.exe $file } catch {} }
    Pause-Return
}

# ---------- FACEBOOK POSTS (prepares text to copy-paste; does NOT auto-post) ----------
function Facebook-Menu {
    while ($true) {
        Clear-Host
        Write-Host "===========================================================" -ForegroundColor Cyan
        Write-Host "  FACEBOOK POSTS" -ForegroundColor Cyan
        Write-Host "===========================================================" -ForegroundColor Cyan
        Write-Host "  This writes the post for you. You copy it and paste it" -ForegroundColor White
        Write-Host "  into Facebook yourself (or schedule it free in Meta" -ForegroundColor White
        Write-Host "  Business Suite). The program does NOT post by itself." -ForegroundColor White
        Write-Host ""
        $ps = @(); if (Test-Path $FbPosts) { $ps = @(Import-Csv $FbPosts) }
        if ($ps.Count -gt 0) {
            Write-Host ("  You have {0} saved post draft(s):" -f $ps.Count)
            foreach ($p in $ps) {
                $flag = if ($p.Posted -eq "yes") { "[POSTED]" } else { "[not posted]" }
                Write-Host ("   #{0} {1}  {2}" -f $p.PostID, $flag, $p.RelatedEvent) -ForegroundColor White
            }
            Write-Host ""
        }
        Write-Host "   A   Create a post for one of my events"
        Write-Host "   V   View / copy a saved post"
        Write-Host "   M   Mark a post as POSTED"
        Write-Host "   0   Back to main menu"
        Write-Host ""
        $ch = Read-Host "  Your choice"
        switch ($ch) {
            {$_ -in "A","a"} { Make-FacebookPost }
            {$_ -in "V","v"} { View-FacebookPost }
            {$_ -in "M","m"} { Mark-PostPosted }
            "0" { return }
        }
    }
}

function Make-FacebookPost {
    Clear-Host
    $evs = @(); if (Test-Path $Events) { $evs = @(Import-Csv $Events) }
    if ($evs.Count -eq 0) {
        Write-Host "  You have no events yet. Add an event first (main menu option 6)." -ForegroundColor Yellow
        Pause-Return; return
    }
    Write-Host "  Which event is this post for?" -ForegroundColor Cyan
    foreach ($e in $evs) { Write-Host ("    #{0} {1}" -f $e.EventID, $e.EventName) }
    Write-Host ""
    $pick = Read-Host "  Event number"
    $ev = $evs | Where-Object { $_.EventID -eq $pick } | Select-Object -First 1
    if (-not $ev) { Write-Host "  I couldn't find that event number." -ForegroundColor Yellow; Pause-Return; return }

    # Build a warm, honest post from the real event details (nothing invented)
    $draft = "Living Way UPC invites you! " + $ev.EventName + "`r`n`r`n"
    if ($ev.Date) { $draft += "When: " + $ev.Date }
    if ($ev.Time) { $draft += " at " + $ev.Time }
    $draft += "`r`n"
    if ($ev.Location)    { $draft += "Where: " + $ev.Location + "`r`n" }
    if ($ev.Description) { $draft += "`r`n" + $ev.Description + "`r`n" }
    $draft += "`r`nEveryone is welcome. We'd love to see you there!`r`n"
    $draft += "- Living Way UPC, 810 Walnut Street, LaPlace, LA  |  (985) 652-7235"

    Clear-Host
    Write-Host "===========================================================" -ForegroundColor Green
    Write-Host "  HERE IS YOUR FACEBOOK POST (review it, then copy it):" -ForegroundColor Green
    Write-Host "===========================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host $draft -ForegroundColor White
    Write-Host ""
    Write-Host "-----------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  TO POST IT:" -ForegroundColor Cyan
    Write-Host "   1. I can copy this to your clipboard - then just paste it"
    Write-Host "      into Facebook (Ctrl+V) and press Post."
    Write-Host ""
    $cp = Read-Host "  Copy this post to the clipboard now? (YES/no)"
    if ($cp -ne "no") {
        try { $draft | Set-Clipboard; Write-Host "  Copied! Open Facebook and press Ctrl+V to paste." -ForegroundColor Green }
        catch { Write-Host "  (Couldn't reach the clipboard - you can copy it from the saved draft instead.)" -ForegroundColor Yellow }
    }

    $id = Next-Id $FbPosts "PostID"
    $row = [pscustomobject]@{
        PostID=$id; RelatedEvent=("#" + $ev.EventID + " " + $ev.EventName); PostType="Event invitation";
        DraftText=$draft; ImageIdea="A friendly photo from a past church event (with permission)";
        CallToAction="Join us!"; CreatedDate=(Get-Date -Format "yyyy-MM-dd"); Posted="no"; PostedDate=""; Notes=""
    }
    Backup-File $FbPosts
    if (Test-Path $FbPosts) { $row | Export-Csv $FbPosts -NoTypeInformation -Append } else { $row | Export-Csv $FbPosts -NoTypeInformation }
    Write-Host ""
    Write-Host ("  Saved as post draft #{0}. (Still marked 'not posted'.)" -f $id) -ForegroundColor Green
    Pause-Return
}

function View-FacebookPost {
    $ps = @(); if (Test-Path $FbPosts) { $ps = @(Import-Csv $FbPosts) }
    if ($ps.Count -eq 0) { Write-Host "  No saved posts yet." -ForegroundColor Yellow; Pause-Return; return }
    $pick = Read-Host "  Which post number"
    $p = $ps | Where-Object { $_.PostID -eq $pick } | Select-Object -First 1
    if (-not $p) { Write-Host "  Couldn't find that number." -ForegroundColor Yellow; Pause-Return; return }
    Clear-Host
    Write-Host "  POST #$($p.PostID)  ($($p.RelatedEvent))" -ForegroundColor Green
    Write-Host ""
    Write-Host $p.DraftText -ForegroundColor White
    Write-Host ""
    $cp = Read-Host "  Copy to clipboard? (YES/no)"
    if ($cp -ne "no") { try { $p.DraftText | Set-Clipboard; Write-Host "  Copied! Paste into Facebook with Ctrl+V." -ForegroundColor Green } catch {} }
    Pause-Return
}

function Mark-PostPosted {
    $ps = @(); if (Test-Path $FbPosts) { $ps = @(Import-Csv $FbPosts) }
    if ($ps.Count -eq 0) { Write-Host "  No saved posts yet." -ForegroundColor Yellow; Pause-Return; return }
    $pick = Read-Host "  Which post number did you post to Facebook"
    $found = $false
    foreach ($p in $ps) { if ($p.PostID -eq $pick) { $p.Posted = "yes"; $p.PostedDate = (Get-Date -Format "yyyy-MM-dd"); $found = $true } }
    if (-not $found) { Write-Host "  Couldn't find that number." -ForegroundColor Yellow; Pause-Return; return }
    Backup-File $FbPosts
    $ps | Export-Csv $FbPosts -NoTypeInformation
    Write-Host "  Marked as posted. Good work!" -ForegroundColor Green
    Pause-Return
}

# ---------- TEAM MESSAGES (prepares texts & phone lists; human sends) ----------
function Team-Menu {
    while ($true) {
        Clear-Host
        Write-Host "===========================================================" -ForegroundColor Cyan
        Write-Host "  TEAM MESSAGES" -ForegroundColor Cyan
        Write-Host "===========================================================" -ForegroundColor Cyan
        Write-Host "  This writes the message AND gathers the phone numbers for" -ForegroundColor White
        Write-Host "  whoever you pick. You paste it into a group text and send." -ForegroundColor White
        Write-Host "  The program does NOT text anyone by itself." -ForegroundColor White
        Write-Host ""
        $vs = @(); if (Test-Path $Volunteers) { $vs = @(Import-Csv $Volunteers) }
        $named = @($vs | Where-Object { $_.FirstName -and $_.FirstName.Trim() -ne "" })
        Write-Host ("  Volunteers on file: {0}" -f $named.Count)
        if ($named.Count -gt 0) {
            $teams = @($named | ForEach-Object { $_.TeamAssignment } | Where-Object { $_ -and $_.Trim() -ne "" } | Sort-Object -Unique)
            if ($teams.Count -gt 0) { Write-Host ("  Teams set up: {0}" -f ($teams -join ", ")) }
            else { Write-Host "  No teams assigned yet (use option A to assign people to teams)." -ForegroundColor Yellow }
        }
        Write-Host ""
        Write-Host "   A   Assign a volunteer to a team (captain or member)"
        Write-Host "   T   View my teams (captains and members)"
        Write-Host "   R   Write a REMINDER / recruitment text"
        Write-Host "   S   Write a 'Share our Facebook post' text"
        Write-Host "   L   Print a phone list for a team"
        Write-Host "   0   Back to main menu"
        Write-Host ""
        $ch = Read-Host "  Your choice"
        switch ($ch) {
            {$_ -in "A","a"} { Assign-Team }
            {$_ -in "T","t"} { Show-Teams }
            {$_ -in "R","r"} { Write-TeamText "reminder" }
            {$_ -in "S","s"} { Write-TeamText "share" }
            {$_ -in "L","l"} { Print-TeamPhones }
            "0" { return }
        }
    }
}

function Get-Volunteers { if (Test-Path $Volunteers) { return @(Import-Csv $Volunteers) } else { return @() } }

function Assign-Team {
    Clear-Host
    $vs = Get-Volunteers
    $named = @($vs | Where-Object { $_.FirstName -and $_.FirstName.Trim() -ne "" })
    if ($named.Count -eq 0) {
        Write-Host "  You have no volunteers yet. Add them in the volunteer sheet" -ForegroundColor Yellow
        Write-Host "  (main menu option 4 opens the data folder), then come back." -ForegroundColor Yellow
        Pause-Return; return
    }
    Write-Host "  WHO are you assigning? Pick a number:" -ForegroundColor Cyan
    for ($i=0; $i -lt $named.Count; $i++) {
        $t = if ($named[$i].TeamAssignment) { "(currently: " + $named[$i].TeamAssignment + ")" } else { "" }
        Write-Host ("   {0}. {1} {2} {3}" -f ($i+1), $named[$i].FirstName, $named[$i].LastName, $t)
    }
    Write-Host ""
    $pick = Read-Host "  Number"
    $idx = 0
    if (-not [int]::TryParse($pick, [ref]$idx) -or $idx -lt 1 -or $idx -gt $named.Count) {
        Write-Host "  That wasn't a valid number." -ForegroundColor Yellow; Pause-Return; return
    }
    $person = $named[$idx-1]
    $team = Read-Host ("  Which team for {0}? (type any team name, example: Red Team)" -f $person.FirstName)
    Write-Host ""
    Write-Host ("  Is {0} the CAPTAIN (leader) of {1}, or a team member?" -f $person.FirstName, $team) -ForegroundColor Cyan
    Write-Host "   C   Captain (team leader)"
    Write-Host "   M   Member"
    $rolePick = Read-Host "  Your choice"
    $isCaptain = ($rolePick -in "C","c","captain","Captain")

    # If this person becomes captain, demote any existing captain of that team to member
    if ($isCaptain) {
        foreach ($v in $vs) {
            if ($v.TeamAssignment -eq $team -and $v.TeamLeader -eq "yes") { $v.TeamLeader = "no" }
        }
    }
    foreach ($v in $vs) {
        if ($v.FirstName -eq $person.FirstName -and $v.LastName -eq $person.LastName -and $v.Phone -eq $person.Phone) {
            $v.TeamAssignment = $team
            $v.TeamLeader = if ($isCaptain) { "yes" } else { "no" }
        }
    }
    Backup-File $Volunteers
    $vs | Export-Csv $Volunteers -NoTypeInformation
    $roleWord = if ($isCaptain) { "CAPTAIN" } else { "member" }
    Write-Host ("  Done. {0} is now {1} of {2}." -f $person.FirstName, $roleWord, $team) -ForegroundColor Green
    if ($isCaptain) { Write-Host "  (Any previous captain of that team is now a member.)" -ForegroundColor DarkGray }
    Pause-Return
}

# ---------- View teams with captains and members ----------
function Show-Teams {
    Clear-Host
    Write-Host "===========================================================" -ForegroundColor Cyan
    Write-Host "  YOUR TEAMS" -ForegroundColor Cyan
    Write-Host "===========================================================" -ForegroundColor Cyan
    Write-Host ""
    $vs = Get-Volunteers
    $named = @($vs | Where-Object { $_.FirstName -and $_.FirstName.Trim() -ne "" })
    $teams = @($named | ForEach-Object { $_.TeamAssignment } | Where-Object { $_ -and $_.Trim() -ne "" } | Sort-Object -Unique)
    if ($teams.Count -eq 0) { Write-Host "  No teams assigned yet. Use 'Assign a volunteer to a team'." -ForegroundColor Yellow; Pause-Return; return }
    foreach ($t in $teams) {
        Write-Host ("  {0}" -f $t) -ForegroundColor Green
        $members = @($named | Where-Object { $_.TeamAssignment -eq $t })
        $cap = @($members | Where-Object { $_.TeamLeader -eq "yes" })
        if ($cap.Count -gt 0) {
            foreach ($c in $cap) { Write-Host ("     CAPTAIN:  {0} {1}  {2}" -f $c.FirstName, $c.LastName, $c.Phone) -ForegroundColor White }
        } else {
            Write-Host "     CAPTAIN:  (none chosen yet)" -ForegroundColor Yellow
        }
        foreach ($m in ($members | Where-Object { $_.TeamLeader -ne "yes" })) {
            Write-Host ("     member:   {0} {1}  {2}" -f $m.FirstName, $m.LastName, $m.Phone) -ForegroundColor Gray
        }
        Write-Host ""
    }
    $unassigned = @($named | Where-Object { -not $_.TeamAssignment -or $_.TeamAssignment.Trim() -eq "" })
    if ($unassigned.Count -gt 0) {
        Write-Host "  NOT YET ON A TEAM:" -ForegroundColor Yellow
        foreach ($u in $unassigned) { Write-Host ("     {0} {1}  {2}" -f $u.FirstName, $u.LastName, $u.Phone) -ForegroundColor Gray }
    }
    Pause-Return
}

function Pick-Recipients {
    # Returns the chosen volunteer rows based on team selection
    $vs = Get-Volunteers
    $named = @($vs | Where-Object { $_.FirstName -and $_.FirstName.Trim() -ne "" -and $_.Phone -and $_.Phone.Trim() -ne "" })
    if ($named.Count -eq 0) { return @() }
    $teams = @($named | ForEach-Object { $_.TeamAssignment } | Where-Object { $_ -and $_.Trim() -ne "" } | Sort-Object -Unique)
    Write-Host "  WHO should get this?" -ForegroundColor Cyan
    Write-Host "   E   Everyone"
    if ($teams.Count -gt 0) {
        Write-Host "   or type a team name exactly, or several separated by commas:"
        Write-Host ("     available teams: {0}" -f ($teams -join ", ")) -ForegroundColor DarkGray
    }
    Write-Host ""
    $sel = Read-Host "  Your choice"
    if ($sel -in "E","e","everyone","Everyone") { return $named }
    $wanted = $sel.Split(",") | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne "" }
    return @($named | Where-Object { $wanted -contains $_.TeamAssignment })
}

function Write-TeamText($kind) {
    Clear-Host
    $recips = Pick-Recipients
    if ($recips.Count -eq 0) {
        Write-Host "  No matching volunteers with phone numbers were found." -ForegroundColor Yellow
        Pause-Return; return
    }

    # Build the message body
    $body = ""
    if ($kind -eq "reminder") {
        Write-Host ""
        $evName = Read-Host "  Event name (example: Saturday Outreach)"
        $when   = Read-Host "  When (example: Sat Oct 17, meet 9:00 AM)"
        $where  = Read-Host "  Where to meet (example: the church)"
        $body = "Hi! Reminder from Living Way UPC: " + $evName + " is coming up"
        if ($when)  { $body += " - " + $when }
        $body += "."
        if ($where) { $body += " Meet at " + $where + "." }
        $body += " We'd love to have you on the team. Reply here if you can make it. Thank you!"
    } elseif ($kind -eq "share") {
        Write-Host ""
        Write-Host "  First, post it on Facebook, then copy the post's link." -ForegroundColor DarkGray
        $link = Read-Host "  Paste the Facebook post link here (or leave blank)"
        $evName = Read-Host "  What's it about (example: our community cookout)"
        $body = "Hi! We just posted about " + $evName + " on the Living Way UPC Facebook page. Would you help us spread the word? Please like it and share it with your friends and family"
        if ($link) { $body += ": " + $link }
        else { $body += " (link coming once it's posted)" }
        $body += ". Thank you for helping us reach our neighbors!"
    }

    # Gather phone numbers
    $phones = @($recips | ForEach-Object { $_.Phone.Trim() })
    $names  = @($recips | ForEach-Object { $_.FirstName })

    Clear-Host
    Write-Host "===========================================================" -ForegroundColor Green
    Write-Host "  YOUR MESSAGE (copy it, paste into a group text):" -ForegroundColor Green
    Write-Host "===========================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host $body -ForegroundColor White
    Write-Host ""
    Write-Host "-----------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host ("  SEND TO these {0} people:" -f $recips.Count) -ForegroundColor Cyan
    for ($i=0; $i -lt $phones.Count; $i++) { Write-Host ("    {0}  -  {1}" -f $names[$i], $phones[$i]) }
    Write-Host ""
    Write-Host "  Phone numbers in one line (easy to paste into a new group text):" -ForegroundColor Cyan
    Write-Host ("    " + ($phones -join ", ")) -ForegroundColor White
    Write-Host ""
    $cp = Read-Host "  Copy the MESSAGE to the clipboard now? (YES/no)"
    if ($cp -ne "no") { try { $body | Set-Clipboard; Write-Host "  Message copied! Start a group text to the numbers above and paste it." -ForegroundColor Green } catch { Write-Host "  (Clipboard unavailable - copy it from the screen.)" -ForegroundColor Yellow } }
    Write-Host ""
    $mk = Read-Host "  Make one-tap TEXT buttons for these people? (YES/no)"
    if ($mk -ne "no") { Make-ClickToText $recips $body }
    Pause-Return
}

# ---------- One-tap click-to-text page (opens texting app pre-filled; human taps Send) ----------
function Html-Escape($s) {
    if (-not $s) { return "" }
    return ($s -replace '&','&amp;' -replace '<','&lt;' -replace '>','&gt;' -replace '"','&quot;')
}

function Make-ClickToText($recips, $body) {
    # Build a simple web page with one button per person.
    # Each button opens the phone's texting app with the number and message
    # already filled in. The person still presses Send themselves (legal + safe).
    $msgEnc = [System.Uri]::EscapeDataString([string]$body)
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine('<!DOCTYPE html><html><head><meta charset="utf-8">')
    [void]$sb.AppendLine('<meta name="viewport" content="width=device-width, initial-scale=1">')
    [void]$sb.AppendLine('<title>Living Way - Send Texts</title>')
    [void]$sb.AppendLine('<style>body{font-family:Arial;margin:16px;background:#f4f6f8;color:#222}')
    [void]$sb.AppendLine('h2{color:#1a7f37}.msg{background:#fff;border:1px solid #ddd;border-radius:8px;padding:12px;margin-bottom:16px;white-space:pre-wrap}')
    [void]$sb.AppendLine('a.btn{display:block;background:#1a7f37;color:#fff;text-decoration:none;padding:14px;border-radius:10px;margin:8px 0;font-size:18px;text-align:center}')
    [void]$sb.AppendLine('.note{color:#666;font-size:14px;margin:12px 0}</style></head><body>')
    [void]$sb.AppendLine('<h2>Living Way UPC - One-Tap Texts</h2>')
    [void]$sb.AppendLine('<div class="note">Open this page ON YOUR PHONE. Tap a name - your texting app opens with the message ready. You press Send. (One person at a time keeps it legal and safe.)</div>')
    [void]$sb.AppendLine('<div class="msg"><b>Message:</b><br>' + (Html-Escape $body) + '</div>')
    foreach ($r in $recips) {
        $ph = ($r.Phone -replace '[^0-9+]','')
        if (-not $ph) { continue }
        $nm = Html-Escape ($r.FirstName + ' ' + $r.LastName)
        [void]$sb.AppendLine('<a class="btn" href="sms:' + $ph + '?&body=' + $msgEnc + '">Text ' + $nm + '  (' + (Html-Escape $r.Phone) + ')</a>')
    }
    [void]$sb.AppendLine('</body></html>')

    $outFolder = Join-Path $KitRoot "send_pages"
    if (-not (Test-Path $outFolder)) { New-Item -ItemType Directory -Path $outFolder -Force | Out-Null }
    $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $file = Join-Path $outFolder ("text_buttons_" + $stamp + ".html")
    $sb.ToString() | Out-File -FilePath $file -Encoding UTF8
    Write-Host ""
    Write-Host "  Made a one-tap TEXT page:" -ForegroundColor Green
    Write-Host ("    " + $file) -ForegroundColor White
    Write-Host "  Open this file ON YOUR PHONE (email it to yourself, or put it" -ForegroundColor DarkGray
    Write-Host "  in a shared folder). Tap each name, then press Send." -ForegroundColor DarkGray
    $op = Read-Host "  Open it now on THIS computer to preview? (YES/no)"
    if ($op -ne "no") { try { Start-Process $file } catch {} }
}

function Print-TeamPhones {
    Clear-Host
    $recips = Pick-Recipients
    if ($recips.Count -eq 0) { Write-Host "  No matching volunteers with phone numbers." -ForegroundColor Yellow; Pause-Return; return }
    Clear-Host
    Write-Host "  PHONE LIST" -ForegroundColor Green
    Write-Host ""
    foreach ($r in $recips) {
        $team = if ($r.TeamAssignment) { $r.TeamAssignment } else { "(no team)" }
        Write-Host ("   {0} {1}  -  {2}   [{3}]" -f $r.FirstName, $r.LastName, $r.Phone, $team)
    }
    Write-Host ""
    $line = ($recips | ForEach-Object { $_.Phone.Trim() }) -join ", "
    Write-Host "  All in one line (to paste into a group text):" -ForegroundColor Cyan
    Write-Host ("    " + $line) -ForegroundColor White
    Write-Host ""
    $cp = Read-Host "  Copy the phone numbers to the clipboard? (YES/no)"
    if ($cp -ne "no") { try { $line | Set-Clipboard; Write-Host "  Copied!" -ForegroundColor Green } catch {} }
    Pause-Return
}

# ---------- Main loop ----------
while ($true) {
    Clear-Host
    Write-Host "===========================================================" -ForegroundColor Green
    Write-Host "        LIVING WAY UPC - OUTREACH HELPER" -ForegroundColor Green
    Write-Host "        For: Don Taylor, Outreach Director" -ForegroundColor Green
    Write-Host "===========================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "  What would you like to do? Type a number and press Enter."
    Write-Host ""
    Write-Host "   1   Import my CHURCH MEMBER list"
    Write-Host "   2   Import an OUTREACH list (people we met at events)"
    Write-Host "   3   See where things stand (a quick summary)"
    Write-Host "   4   Open my data folder (to view/print the spreadsheets)"
    Write-Host "   5   Read the Quick Start guide"
    Write-Host ""
    Write-Host "   6   Events  (add or view any event)" -ForegroundColor Cyan
    Write-Host "   7   Campaigns  (group events + make a playbook)" -ForegroundColor Cyan
    Write-Host "   8   Facebook posts  (write a post to copy & paste)" -ForegroundColor Cyan
    Write-Host "   9   Team Messages  (captains, members, reminders)" -ForegroundColor Cyan
    Write-Host "  10   Field Map & Team Chat  (free pins + notifications)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   0   Quit"
    Write-Host ""
    $choice = Read-Host "  Your choice"
    switch ($choice) {
        "1"  { Import-List $Members "CHURCH MEMBER LIST" }
        "2"  { Import-List $Contacts "OUTREACH LIST" }
        "3"  { Show-Summary }
        "4"  { Open-DataFolder }
        "5"  { Start-Process notepad.exe (Join-Path $KitRoot "READ ME FIRST.txt") }
        "6"  { Event-Menu }
        "7"  { Campaign-Menu }
        "8"  { Facebook-Menu }
        "9"  { Team-Menu }
        "10" { FieldMap-Menu }
        "0"  { Clear-Host; Write-Host "  Goodbye! God bless." -ForegroundColor Green; Start-Sleep 1; return }
        default { }
    }
}
