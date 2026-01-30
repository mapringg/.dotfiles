function hapi
    if test -n "$API_COOKIE"
        http $argv Cookie:"$API_COOKIE"
    else if test -n "$API_TOKEN"
        http $argv Authorization:"Bearer $API_TOKEN"
    else
        echo "Set API_TOKEN or API_COOKIE in .env"
    end
end
