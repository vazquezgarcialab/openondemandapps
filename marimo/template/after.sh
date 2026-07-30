# Wait for the marimo server to start
echo "Waiting for marimo to open port ${port}..."
if wait_until_port_used "${host}:${port}" 60; then
  echo "Discovered marimo listening on port ${port}!"
else
  echo "Timed out waiting for marimo to open port ${port}!"
  pkill -P ${SCRIPT_PID}
  clean_up 1
fi
sleep 2
