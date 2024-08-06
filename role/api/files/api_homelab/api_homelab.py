from fastapi import FastAPI, HTTPException
from fastapi.responses import RedirectResponse
import subprocess
from enum import Enum

app = FastAPI()

class ProxmoxNodes(str, Enum):
    node2 = "n2-cls1.homelab.lan"
    node3 = "n3-cls1.homelab.lan"

def proxmox_node_fqdn(node: ProxmoxNodes):
    if node == ProxmoxNodes.node2:
        return "n2-cls1.homelab.lan"
    elif node == ProxmoxNodes.node3:
        return "n3-cls1.homelab.lan"

def execute_ssh_command(node: str, command: str):
    ssh_command = f"ssh root@{node} \"{command}\""
    command_result = subprocess.check_output(ssh_command, shell=True, text=True).strip()
    return command_result

@app.get("/")
async def root():
    return RedirectResponse(url="/docs")

# Control fan speed for n[2-3]-cls1.homelab.lan
# max_fan_speed = 9250 RPM
# fan_speed = 0% : pinctrl FAN_PWM op dh
# fan_speed = 100% : pinctrl FAN_PWM op dl
# fan_speed auto : pinctrl FAN_PWM a0

@app.get("/get_fan_speed/{node}")
async def get_fan_speed(node: ProxmoxNodes):
    node = proxmox_node_fqdn(node)
    fan_speed = execute_ssh_command(node, "cat /sys/devices/platform/cooling_fan/hwmon/hwmon*/fan1_input")
    fan_speed_percentage = execute_ssh_command(node, "echo \$(cat /sys/devices/platform/cooling_fan/hwmon/hwmon*/fan1_input) \* 100 / 9250 | bc")
    return {"Fan speed": fan_speed + " RPM", "Fan speed percentage": fan_speed_percentage + "%"}

@app.post("/auto_fan_speed/{node}")
async def auto_fan_speed(node: ProxmoxNodes):
    node = proxmox_node_fqdn(node)
    command_output = execute_ssh_command(node, "pinctrl FAN_PWM a0")
    return f"{command_output}The fan speed is set to automatic on {node}."

@app.post("/stop_fan_speed/{node}")
async def stop_fan_speed(node: ProxmoxNodes):
    node = proxmox_node_fqdn(node)
    command_output = execute_ssh_command(node, "pinctrl FAN_PWM op dh")
    return f"{command_output}The fan is stopped on {node}."

@app.post("/max_fan_speed/{node}")
async def max_fan_speed(node: ProxmoxNodes):
    node = proxmox_node_fqdn(node)
    command_output = execute_ssh_command(node, "pinctrl FAN_PWM op dl")
    return f"{command_output}The fan speed is set to maximum on {node}."
