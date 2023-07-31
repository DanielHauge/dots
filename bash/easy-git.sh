
alias gs='git status'

function gd () {
    local index=1

    local file="$(git ls-files -d | head -$index)"
    if [ -n "$file" ]; then
        echo -e "Deleted file \033[41m $file\033[0m"
        echo -e "\033[91m$(git show HEAD:$file | sed -e 's/^/-/')\033[0m "
        return
    fi

    local file="$(git ls-files -m | head -$index)"
    if [ -n "$file" ]; then
        git diff $file
        return
    fi

    local file="$(git ls-files -o | head -$index)"
    if [ -n "$file" ]; then
        echo -e "Added new file \033[44m\033[92m $file \033[0m "
        while read p; do
            echo -e "\033[92m+$p\033[0m"   
        done <$file
        return
    fi

    echo "No file to diff"

    git status
}

function ga () {
    local file="$(git ls-files -d | head -$index)"
    if [ -n "$file" ]; then
        git add $file
        git status
        return
    fi
    
    local file="$(git ls-files -m | head -$index)"
    if [ -n "$file" ]; then
        git add $file
        git status
        return
    fi

    local file="$(git ls-files -o | head -$index)"
    if [ -n "$file" ]; then
        git add $file
        git status
        return
    fi

    echo "No file to add"

    git status
}

function gc () {
    local file="$(git ls-files -d | head -$index)"
    if [ -n "$file" ]; then
        git restore $file
        echo "Restored $file from head"
        git status
        return
    fi
    
    local file="$(git ls-files -m | head -$index)"
    if [ -n "$file" ]; then
        git restore $file
        echo "Restored $file from head"
        git status
        return
    fi

    local file="$(git ls-files -o | head -$index)"
    if [ -n "$file" ]; then
        rm $file
        echo "Removed $file"
        git status
        return
    fi

    echo "No file to restore"

    git status
}

function grm () {
    local file="$(git ls-files --format='%(path)' | head -$index)"
    if [ -n "$file" ]; then
        git rm --cached $file
        echo "Removed $file from staging"
        git status
        return
    fi
    
    echo "No file to remove from staging"
}