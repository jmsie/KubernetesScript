while [ 1 ]                                                                                                                                                        
do
    web_page=$(curl -s http://35.241.53.155 | grep h1 |sed "s/<h1>//g" | sed "s/<\/h1>//g")
    ping_val=$(ping -c 1 google.com | awk 'BEGIN {FS="[=]|[ ]"} {print $10}')
    echo $web_page ", Time:" $ping_val
    sleep 2
done
