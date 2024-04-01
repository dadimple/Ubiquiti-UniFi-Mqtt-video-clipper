Save a videoclip at a specific timestamp from a camera recorded on a Ubiquiti UniFi Cloudkey. The recording time before and after the timestamp can be set.
The timestamp is obtained via MQTT (epoch time) and must be published with retain flag is true. The retain flag is cleared by the script after a clip has been saved.
This script can be scheduled every minute. In that case, a maximum of one clip per minute can be saved.

To select the required camera go to Unify Protect in your webbrowser. Select the camera and take note of the url.
