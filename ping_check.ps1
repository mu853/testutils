function convertunixtime( $line ) {
    $tmp = $line -split " "
    $tmp[0] = "[{0}]" -F ( unix2date( gettimestamp ( $line ) ) )
    $tmp -join " "
}

function gettimestamp( $line ) {
    ( ( $line -split " ")[0].trim( "[]" ) -split "\." )[0]
}

function unix2date( $unixtime ) {
    $origin = New-Object -Type DateTime -ArgumentList 1970, 1, 1, 0, 0, 0, 0
    $origin.AddSeconds( $unixtime ).ToLocalTime()
}

function check( $filepath ) {
    "[{0}]" -F $filepath.fullname
    
    $c = 1
    $prev_seq = 1
    $prev_line = ""
    gc $filepath | select-string "icmp_seq" | %{
        $line = $_
        [int]$seq = ( ( $line -split " " )[5] -split "=" )[1]
        
        if ( $seq -eq 1 ) { $c = 1 }
        if ( $seq -ne $c ) {
            "loss detected, downtime = {0} s" -F ( $seq - $prev_seq ) | Write-Host -ForegroundColor Yellow
            "------" | Write-Host
            convertunixtime( $prev_line ).ToString() | Write-Host
            convertunixtime( $line ).ToString() | Write-Host
            "------" | Write-Host
            $c = $seq
        }
        $prev_line = $line
        $prev_seq = $seq
        $c++
    }
    
    $msg = ""
    gc $filepath | select-string "packet loss" | %{
        $msg = ($_ -split ", ")[2]
    }

    $ping_result = gc $filepath | select-string "icmp_seq"
    $start_time = unix2date( gettimestamp( $ping_result[0] ) )
    $end_time = unix2date( gettimestamp( $ping_result[$ping_result.length - 1] ) )

    "{0} ({1} - {2})" -F $msg, $start_time.ToLongTimeString(), $end_time.ToLongTimeString() | Write-Host -ForegroundColor Green
}

ls -R *ping.log | %{ check $_ }
