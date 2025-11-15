#!/bin/bash


RED='\033[0;31m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' #Rs

banner() {
echo -e "${WHITE}"
echo "=========================================="
echo "          HTML DECRYPTOR TOOL"
echo "       Deobfuscate Malz Encrypted HTML"
echo "=========================================="
echo ""
echo ""
echo "Developer By Andrax32, Reverse Egineer Tools"
echo "Donate nya kakak :v : https://saweria.co/andraxdev"
echo "Star nya ding kakak :v : https://github.com/Lupepeksokhekeljink"
echo ""
echo ""
echo -e "${NC}"
}

function 64() {
    echo "$1" | base64 -d 2>/dev/null
}

function url() {
    echo "$1" | sed 's/+/ /g; s/%/\\x/g' | xargs -0 printf "%b"
}

function menu() {
    echo -e "\n${WHITE}[+]${RED} Menu Decryption:${NC}"
    echo -e "  ${WHITE}[1]${GRAY} Decrypt Hard enc html${NC}"
    echo -e "  ${WHITE}[2]${GRAY} Decrypt Slow enc html${NC}"
    echo -e "  ${WHITE}[3]${GRAY} Exit${NC}"
    echo ""
}

decrypt_hard() {
    local input_file="$1"
    local output_file="DeobfByAndrax_$(basename "$input_file")"
    
    echo -e "${GRAY}[*] Processing Hard encryption decryption...${NC}"
    
    encrypted_string=$(grep -o 'let e="[^"]*"' "$input_file" | sed 's/let e="//' | sed 's/"//')
    
    if [ -z "$encrypted_string" ]; then
        echo -e "${RED}[!] Could not find encrypted string in the file${NC}"
        return 1
    fi
    
    echo -e "${GRAY}[*] Encrypted string found (length: ${#encrypted_string})${NC}"
    
    echo -e "${GRAY}[*] Decoding URL layer...${NC}"
    layer4=$(url "$encrypted_string")
    
    echo -e "${GRAY}[*] Decoding Base64 layer 3...${NC}"
    layer3=$(64 "$layer4")
    
    if [ -z "$layer3" ]; then
        echo -e "${RED}[!] Failed to decode Base64 layer 3${NC}"
        return 1
    fi
    
    echo -e "${GRAY}[*] Processing chunk decoding...${NC}"
    layer2=""
    IFS='|' read -ra chunks <<< "$layer3"
    for chunk in "${chunks[@]}"; do
        decoded_chunk=$(64 "$chunk")
        layer2="${layer2}${decoded_chunk}"
    done
    
    echo -e "${GRAY}[*] Decoding final Base64 layer...${NC}"
    layer1=$(64 "$layer2")
    
    if [ -z "$layer1" ]; then
        echo -e "${RED}[!] Failed to decode final Base64 layer${NC}"
        return 1
    fi
    
    echo "$layer1" > "$output_file"
    
    echo -e "${WHITE}[+] Successfully decrypted Hard encryption!${NC}"
    echo -e "${GRAY}[*] Output saved to: $output_file${NC}"
    echo -e "${GRAY}[*] Original content size: ${#layer1} characters${NC}"
    
    return 0
}

decrypt_slow() {
    local input_file="$1"
    local output_file="DeobfByAndrax_$(basename "$input_file")"
    
    echo -e "${GRAY}[*] Processing Slow encryption decryption...${NC}"
    
    encrypted_string=$(grep -o 'let e="[^"]*"' "$input_file" | sed 's/let e="//' | sed 's/"//')
    
    if [ -z "$encrypted_string" ]; then
        echo -e "${RED}[!] Could not find encrypted string in the file${NC}"
        return 1
    fi
    
    echo -e "${GRAY}[*] Encrypted string found (length: ${#encrypted_string})${NC}"
    
    echo -e "${GRAY}[*] Decoding URL layer...${NC}"
    layer3=$(url "$encrypted_string")
    
    echo -e "${GRAY}[*] Decoding Base64 layer 2...${NC}"
    layer2=$(64 "$layer3")
    
    if [ -z "$layer2" ]; then
        echo -e "${RED}[!] Failed to decode Base64 layer 2${NC}"
        return 1
    fi
    
    echo -e "${GRAY}[*] Decoding Base64 layer 1...${NC}"
    layer1=$(64 "$layer2")
    
    if [ -z "$layer1" ]; then
        echo -e "${RED}[!] Failed to decode Base64 layer 1${NC}"
        return 1
    fi
    
    echo "$layer1" > "$output_file"
    
    echo -e "${WHITE}[+] Successfully decrypted Slow encryption!${NC}"
    echo -e "${GRAY}[*] Output saved to: $output_file${NC}"
    echo -e "${GRAY}[*] Original content size: ${#layer1} characters${NC}"
    
    return 0
}

detect_encryption_type() {
    local file="$1"
    
    if grep -q "Multi-layer decoder" "$file" && grep -q 'split("|")' "$file"; then
        echo "hard"
    elif grep -q "Encrypted by Malz" "$file" && grep -q 'atob(atob' "$file"; then
        echo "slow"
    else
        echo "unknown"
    fi
}

while true; do
    clear
    banner
    menu
    read -p "Select option [1-3]: " choice
    
    case $choice in
        1|2)
            echo ""
            read -p "File Obfuscator -->>>> : " input_file
            
            # Check if file exists and has .html extension
            if [ ! -f "$input_file" ]; then
                echo -e "${RED}[!] File not found: $input_file${NC}"
                continue
            fi
            
            if [[ ! "$input_file" =~ \.html$ ]]; then
                echo -e "${RED}[!] File must have .html extension${NC}"
                continue
            fi
            
            # Auto-detect encryption type
            encryption_type=$(detect_encryption_type "$input_file")
            echo -e "${GRAY}[*] Detected encryption type: $encryption_type${NC}"
            
            if [ "$choice" = "1" ]; then
                if [ "$encryption_type" != "hard" ]; then
                    echo -e "${RED}[!] Warning: File doesn't appear to be Hard encrypted${NC}"
                    read -p "Continue anyway? (y/n): " confirm
                    if [[ ! $confirm =~ ^[Yy]$ ]]; then
                        continue
                    fi
                fi
                decrypt_hard "$input_file"
            elif [ "$choice" = "2" ]; then
                if [ "$encryption_type" != "slow" ]; then
                    echo -e "${RED}[!] Warning: File doesn't appear to be Slow encrypted${NC}"
                    read -p "Continue anyway? (y/n): " confirm
                    if [[ ! $confirm =~ ^[Yy]$ ]]; then
                        continue
                    fi
                fi
                decrypt_slow "$input_file"
            fi
            ;;
        3)
            echo -e "${GRAY}[*] Exiting...${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}[!] Invalid option${NC}"
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
done