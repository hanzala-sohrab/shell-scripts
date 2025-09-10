#!/bin/zsh

# VPN Configuration - Store sensitive data in environment variables
readonly TOTP_SECRET="${VPN_TOTP_SECRET:-MLYYSJBLOTTDSXD6}"

# VPN Configuration Map
declare -A VPN_CONFIGS=(
    ["hirist"]="/net/openvpn/v3/configuration/80930f3exc44ax4876xbf1ax8bc0946f78c6:Hirist VPN"
    ["global"]="/net/openvpn/v3/configuration/d9e58a57x9d41x450axb72cxa403467e9c6a:Global VPN"
    ["updazz"]="/net/openvpn/v3/configuration/b780cf5exe90ex4aa4xbefcx52182c6981ae:Updazz/Engineeristic/Biojoby VPN"
    ["oregon"]="/net/openvpn/v3/configuration/be82effbx2051x431bxa24exca4b46aa59aa:Oregon VPN"
    ["iimjobs"]="/net/openvpn/v3/configuration/0f27e462xced7x4d56xa0edx87b0bc520f9f:IIMJobs VPN"
)

# Color codes for better output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Function to display script usage
display_usage() {
    cat << EOF
Usage: vpn [options]

Options:
  help    Display this help message
  c       Connect to all VPNs (IIMJobs, Hirist, Global, Oregon, Updazz)
  d       Disconnect from all active VPNs
  l       List active VPN sessions
  h       Connect to Hirist VPN
  i       Connect to IIMJobs VPN
  g       Connect to Global VPN
  o       Connect to Oregon VPN
  u       Connect to Updazz/Engineeristic/Biojoby VPN
  r       Refresh VPN connections (disconnect all, then connect all)

Environment Variables:
  VPN_TOTP_SECRET    TOTP secret for IIMJobs VPN (default: hardcoded value)
EOF
}

# Function to validate arguments
validate_args() {
    if [ $# -eq 0 ]; then
        log_error "Missing option"
        display_usage
        exit 1
    elif [ $# -gt 1 ]; then
        log_error "Extra options not acceptable"
        display_usage
        exit 1
    fi
}

# Function to connect to a specific VPN
connect_vpn() {
    local vpn_key="$1"
    local config_info="${VPN_CONFIGS[$vpn_key]}"
    
    if [[ -z "$config_info" ]]; then
        log_error "Unknown VPN configuration: $vpn_key"
        return 1
    fi
    
    local config_path="${config_info%%:*}"
    local vpn_name="${config_info##*:}"
    
    log_info "Connecting to $vpn_name..."
    
    # Special handling for IIMJobs VPN (requires TOTP)
    if [[ "$vpn_key" == "iimjobs" ]]; then
        if ! command -v oathtool >/dev/null 2>&1; then
            log_error "oathtool is required for IIMJobs VPN but not installed"
            return 1
        fi
        
        if ! command -v expect >/dev/null 2>&1; then
            log_error "expect is required for IIMJobs VPN automation but not installed"
            return 1
        fi
        
        local totp_code
        if ! totp_code=$(oathtool -b --totp "$TOTP_SECRET" 2>/dev/null); then
            log_error "Failed to generate TOTP token"
            return 1
        fi
        log_info "Generated TOTP token for authentication"
        
        # Use expect to automatically input the TOTP code
        local max_retries=2
        local attempt=1
        
        while [ $attempt -le $max_retries ]; do
            log_info "Attempting connection (attempt $attempt/$max_retries)..."
            
            if expect -c "
                set timeout 30
                spawn openvpn3 session-start --config-path \"$config_path\"
                expect {
                    \"Enter Authenticator Code:\" {
                        send \"$totp_code\r\"
                        expect eof
                        exit 0
                    }
                    timeout {
                        exit 1
                    }
                    eof {
                        exit 0
                    }
                }
            " >/dev/null 2>&1; then
                log_success "Successfully connected to $vpn_name"
                return 0
            else
                log_warning "Connection attempt $attempt failed for $vpn_name"
                ((attempt++))
                # Generate new TOTP code for retry
                if [ $attempt -le $max_retries ]; then
                    sleep 2
                    if ! totp_code=$(oathtool -b --totp "$TOTP_SECRET" 2>/dev/null); then
                        log_error "Failed to generate TOTP token for retry"
                        return 1
                    fi
                fi
            fi
        done
        
        log_error "Failed to connect to $vpn_name after $max_retries attempts"
        return 1
    fi
    
    # Standard connection for other VPNs
    local max_retries=2
    local attempt=1
    
    while [ $attempt -le $max_retries ]; do
        if openvpn3 session-start --config-path "$config_path" 2>/dev/null; then
            log_success "Successfully connected to $vpn_name"
            return 0
        else
            log_warning "Connection attempt $attempt failed for $vpn_name"
            ((attempt++))
        fi
    done
    
    log_error "Failed to connect to $vpn_name after $max_retries attempts"
    return 1
}

# Function to connect to all VPNs
connect_all() {
    echo "============================================================================="
    log_info "Connecting to all VPNs..."
    echo "============================================================================="
    
    local failed_connections=0
    
    for vpn_key in iimjobs hirist global updazz oregon; do
        if ! connect_vpn "$vpn_key"; then
            ((failed_connections++))
        fi
        echo
    done
    
    echo "============================================================================="
    if [ $failed_connections -eq 0 ]; then
        log_success "All VPN connections established successfully"
    else
        log_warning "$failed_connections VPN connection(s) failed"
    fi
    echo "============================================================================="
    
    return $failed_connections
}

# Function to disconnect from all VPNs
disconnect_all() {
    local session_paths=($(openvpn3 sessions-list 2>/dev/null | grep -i 'path' | awk '{print $2}'))
    local config_names=($(openvpn3 sessions-list 2>/dev/null | grep -i 'config name' | awk '{print $3}'))
    local number_of_sessions=${#session_paths[@]}
    
    if [ "$number_of_sessions" -eq 0 ]; then
        log_info "No active VPN sessions found"
        return 0
    fi
    
    log_info "Found $number_of_sessions active session(s)"
    echo "============================================================================="
    
    local disconnected=0
    for ((i=1; i<=number_of_sessions; i++)); do
        local session="${session_paths[i]}"
        local config_name="${config_names[i]}"
        
        # Determine VPN name based on config name
        local vpn_display_name="Unknown VPN"
        case "$config_name" in
            *iimjobs*) vpn_display_name="IIMJobs VPN" ;;
            *hirist*) vpn_display_name="Hirist VPN" ;;
            *global*) vpn_display_name="Global VPN" ;;
            *oregon*) vpn_display_name="Oregon VPN" ;;
            *updazz*) vpn_display_name="Updazz/Engineeristic/Biojoby VPN" ;;
        esac
        
        log_info "Disconnecting $vpn_display_name..."
        if openvpn3 session-manage -D --session-path "$session" 2>/dev/null; then
            log_success "Disconnected $vpn_display_name"
            ((disconnected++))
        else
            log_error "Failed to disconnect $vpn_display_name"
        fi
    done
    
    echo "============================================================================="
    log_info "Disconnected $disconnected out of $number_of_sessions session(s)"
    echo "============================================================================="
}

# Function to list active sessions
list_sessions() {
    log_info "Active VPN sessions:"
    echo "============================================================================="
    if ! openvpn3 sessions-list; then
        log_error "Failed to list VPN sessions"
        return 1
    fi
    echo "============================================================================="
}

# Main script logic
main() {
    validate_args "$@"
    
    local option="$1"
    
    case "$option" in
        help)
            display_usage
            exit 0
            ;;
        c)
            connect_all
            ;;
        d)
            disconnect_all
            ;;
        l)
            list_sessions
            ;;
        i)
            connect_vpn "iimjobs"
            ;;
        h)
            connect_vpn "hirist"
            ;;
        g)
            connect_vpn "global"
            ;;
        o)
            connect_vpn "oregon"
            ;;
        u)
            connect_vpn "updazz"
            ;;
        r)
            log_info "Refreshing VPN connections..."
            disconnect_all
            echo
            connect_all
            ;;
        *)
            log_error "Invalid option: $option"
            display_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
