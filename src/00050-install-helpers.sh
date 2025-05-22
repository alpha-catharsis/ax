####################################
# 00050-intall-helpers section START
####################################

# set environment variable
function env_set {
    export "${1}"="${2}"
    entry "set environment variable [>var:${1}] to [>val:${2}]"
}

##################################
# 00050-intall-helpers section END
##################################
