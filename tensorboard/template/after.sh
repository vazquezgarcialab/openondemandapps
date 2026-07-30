# Wait for the TensorBoard server to start
echo "Waiting for TensorBoard to open port ${port}..."
if wait_until_port_used "${host}:${port}" 60; then
  echo "Discovered TensorBoard listening on port ${port}!"
else
  echo "Timed out waiting for TensorBoard to open port ${port}!"
  pkill -P ${SCRIPT_PID}
  clean_up 1
fi
sleep 2
