# 6. COMPLETION
echo "--- INIT COMPLETED SUCCESSFULLY ---"
touch /etc/cloud/cloud-init.disabled

echo "=== VM Initialization Completed at $(date) ==="

# Reboot logic
echo "[INFO] Rebooting..."
reboot || echo "Standard reboot failed, trying force..."
reboot -f || echo "Force reboot failed, trying sysrq..."
echo b > /proc/sysrq-trigger
