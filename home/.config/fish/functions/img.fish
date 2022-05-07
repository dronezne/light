function img
    if test -d ~/Pictures
        imv -f -r ~/Pictures >/dev/null 2>&1 & disown
    else
        echo "$HOME/Pictures does not exist"
    end
end
