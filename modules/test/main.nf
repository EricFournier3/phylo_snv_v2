

process TEST {


    script:
    """
    echo "IN TEST"
    echo "ericf" 
    echo "${params.test}"
    """


}


