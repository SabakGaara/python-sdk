# Python SDK

Python SDK provides the python API for FISCO BCOS. You can quickly develop your blockchain applications based on Python SDK. This repository further improve the capabilities of original Python SDK of FISCO BCOS. Specifically, we add following key feature on Python SDK


## Key Feature

- Support more complex transaction input parameters, such as arrays, etc.
- Add an interface for specifying the transaction transfer amount

## Environmental requirements:

- **Python Version**: python 3.6.3, 3.7.x

- **FISCO BCOS Nodes**: refer to [here](https://fisco-bcos-documentation.readthedocs.io/en/latest/docs/installation.html) 

- **Ubuntu**: `sudo apt install -y zlib1g-dev libffi6 libffi-dev wget git`

- **CentOS**：`sudo yum install -y zlib-devel libffi-devel wget git`

- **MacOs**: `brew install wget npm git`

**Install dependencies**:

```bash
cd python-sdk 
pip install -r requirements.txt
```

## Initial configuration (can be skipped in Windows environment)

```bash
# The script performs operations as follows:
# 1. Copy client_config.py.template->client_config.py
# 2. Install solc compiler
bash init_env.sh -i
```

## Configure Channel communication protocol

Python SDK supports the use of [Channel protocol](https://fisco-bcos-documentation.readthedocs.io/zh_CN/latest/docs/design/protocol_description.html#channelmessage-v1) to communicate with FISCO BCOS nodes, which is secured by SSL encrypted communication The confidentiality of the communication between the SDK and the node.

Suppose the nodes connected to the SDK are deployed in the directory `~/fisco/nodes/127.0.0.1`, then use the Channel protocol through the following steps:

**Configure Channel Information**

Obtain channel_listen_port in the config.ini file in the node directory, here is 20200
```bash
[rpc]
     listen_ip=0.0.0.0
     channel_listen_port=20200
     jsonrpc_listen_port=8545
```

Switch to the python-sdk directory and modify the `channel_host` in the client_config.py file to be the actual IP, and `channel_port` to the `channel_listen_port` obtained in the previous step:

```bash
channel_host = "127.0.0.1"
channel_port = 20200
```

**Configuration Certificate**

```bash
# If the node and python-sdk are located on different machines, please copy all relevant files in the node's sdk directory to the bin directory
# If the node and SDK are located on the same machine, directly copy the node certificate to the SDK configuration directory
cp ~/fisco/nodes/127.0.0.1/sdk/* bin/
```

**Configure certification path**

  -`channel_node_cert` and `channel_node_key` options of `client_config.py` are used to configure SDK certificate and private key respectively
  -Starting from the `release-2.1.0` version, the SDK certificate and private key are updated to `sdk.crt` and `sdk.key`. Before configuring the certificate path, please check the certificate name and private key name copied in the previous step, and `channel_node_cert` is configured as SDK certificate path, `channel_node_key` is configured as SDK private key path

Check the SDK certificate path copied from the node. If the SDK certificate and private key paths are `bin/sdk.crt` and `bin/sdk.key`, the relevant configuration items in `client_config.py` are as follows:

```bash
channel_node_cert = "bin/sdk.crt" # When using the channel protocol, you need to set the sdk certificate, if you use the rpc protocol to communicate, you can leave it blank here
channel_node_key = "bin/sdk.key" # When using the channel protocol, you need to set the sdk private key. If you use the rpc protocol to communicate, you can leave it blank here
```

If the SDK certificate and private key paths are `bin/node.crt` and `bin/node.key` respectively, the relevant configuration items in `client_config.py` are as follows:
```bash
channel_node_cert = "bin/node.crt" # When using the channel protocol, you need to set the sdk certificate, if you use the rpc protocol to communicate, you can leave it blank here
channel_node_key = "bin/node.key" # When using the channel protocol, you need to set the sdk private key, if you use the rpc protocol to communicate, you can leave it blank here
```
**Use the Channel protocol to access the node**

```bash
# Get the version number of the FISCO BCOS node
./console.py getNodeVersion
```

## SDK usage example

**See how to use SDK**

> **To execute console.py in windows environment, please use `.\console.py` or `python console.py`**

```bash
# View SDK usage
./console.py usage

# Get node version
./console.py getNodeVersion
```

**Deploy HelloWorld Contract**

```bash
$ ./console.py deploy HelloWorld 1 save 
# 1 is the amount of balance attached on this transaction
INFO >> user input : ['deploy', 'HelloWorld', 'save']

backup [contracts/HelloWorld.abi] to [contracts/HelloWorld.abi.20190807102912]
backup [contracts/HelloWorld.bin] to [contracts/HelloWorld.bin.20190807102912]
INFO >> compile with solc compiler
deploy result  for [HelloWorld] is:
 {
    "blockHash": "0x3912605dde5f7358fee40a85a8b97ba6493848eae7766a8c317beecafb2e279d",
    "blockNumber": "0x1",
    "contractAddress": "0x2d1c577e41809453c50e7e5c3f57d06f3cdd90ce",
    "from": "0x95198b93705e394a916579e048c8a32ddfb900f7",
    "gasUsed": "0x44ab3",
    "input": "0x6080604052.....c6f2c20576f726c642100000000000000000000000000",
    "logs": [],
    "logsBloom": "0x000...0000",
    "output": "0x",
    "status": "0x0",
    "to": "0x0000000000000000000000000000000000000000",
    "transactionHash": "0xb291e9ca38b53c897340256b851764fa68a86f2a53cb14b2ecdcc332e850bb91",
    "transactionIndex": "0x0"
}
on block : 1,address: 0x2d1c577e41809453c50e7e5c3f57d06f3cdd90ce 
address save to file:  bin/contract.ini
```

**Call functions in deployed HelloWorld Contract**
```bash
$ ./console.py sendtx HelloWorld 0x2d1c577e41809453c50e7e5c3f57d06f3cdd90ce get 0
# 0 is the amount of balance attached on this transaction
# 0x2d1c577e41809453c50e7e5c3f57d06f3cdd90ce is the address of deployed contract HelloWorld.
```
