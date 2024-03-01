# Palworld Dedicated Server Setup

Palworld Dedciated Server 를 셋업하는데 필요한 작업들을 스크립트화 해놓았습니다.

상세한 설명은 [Palworld Technical Guide](https://tech.palworldgame.com/) 를 참고하세요.

## System Requirements
아래와 같은 사양의 머신에서 테스트를 진행하였습니다.

CPU 는 x86 기반 프로세서 (인텔 or AMD) 를 권장합니다.
| 리소스 | 사양                                          |
| ------ | --------------------------------------------- |
| OS     | Ubuntu 22.04.4 LTS                            |
| CPU    | Intel i7-4790K @ 4.0GHz / 4 cores             |
| RAM    | DDR3-1600 24GB                                |
| SSD    | MX500 1TB                                     |


## Prerequisites

Linux 머신에 접속하기 위해서는 SSH client 가 필요합니다. 
[MobaXterm](https://mobaxterm.mobatek.net/), [PuTTY](https://www.putty.org/) 등 편한 client 를 사용하시면 됩니다.

서버를 bash 에서 조작하기 위해서 rcon 을 사용합니다. 
본 구현에서는 [rcon-cli](https://github.com/gorcon/rcon-cli) 의 release_v.0.10.3 을 사용하였습니다.

관리자계정 (root) 을 사용하지 마세요. Palworld Dedciated Server 는 관리자계정에서는 구동할 수 없습니다.

## Install

Palworld server 설치에 필요한 모든 command 의 script 입니다. 아래 명령을 사용해서 설치하세요.

```
bash install.sh
```

Palworld server 운용에 필요한 Ubuntu package 설치를 위해 중간에 관리자권한 (sudo) 를 요청합니다.

또, Steam Client ([steamcmd](https://developer.valvesoftware.com/wiki/SteamCMD#Linux), Dedicated Server 를 위해 Steam 에서 제공하는 툴) 약관에 동의를 수동으로 해야합니다.

Enter 키를 누르면서 약관을 읽고 동의(2) 를 입력하면 설치가 정상적으로 진행됩니다.

Palworld Dedicated Server 폴더의 기본위치 `${HOME}/Steam` 입니다. 아래 명령어를 사용하여 Palworld Dedicated Server 설치경로로 이동합니다.

```
cd ${HOME}/Steam/steamapps/common/PalServer
```

## Deploy Palworld Dedciated Server

### Tmux 활용하기

기본적으로 SSH client 를 종료하면 유저가 구동 중이던 프로세스도 같이 종료되어 server 도 같이 종료가 되어버립니다.

Tmux 를 사용하면 SSH client 를 종료해도 프로세스가 종료되지 않고 계속 실행 중인 상태가 됩니다.

서버 정비가 필요한 경우 SSH client 에서 tmux session 을 attach 하면 손쉽게 사용가능합니다.

상세한 tmux 사용법은 [Tmux Wiki](https://github.com/tmux/tmux/wiki) 를 참고하세요.

SSH client 상에서 기초적인 tmux 사용법은 아래와 같습니다.

tmux 시작:

```
tmux
```

실행 중인 tmux session 확인:

```
tmux ls
```

Tmux session attach (여러 tmux session 이 있지 않은 이상 session_id = 0):

```
tmux a -t [session_id]
```

Tmux session 안에서 유용한 키조합:
| 키조합 | 동작                                          |
| ------ | --------------------------------------------- |
| ctrl + b, d | tmux session detach                      |
| ctrl + b, $ | tmux window 세로 분할                     |
| ctrl + b, " | tmux window 가로 분할                     |
| ctrl + b, 방향키 | tmux window 간 이동                  |
| ctrl + b, x | tmux window 종료                         |

### Deploy Palworld Dedciated Server

현재 버전 기준 (v0.1.5.1) Palworld Dedciated Server 는 메모리 누수 문제가 있는것으로 알려져 있습니다.

이로 인해 Palworld Dedicated Server 가 예기치 않게 종료되는 문제가 있습니다.

이를 해결하기 위해 본 repository 의 해결은 다음과 같습니다.
- 일정 시간 (10초) 간격으로 서버의 메모리 사용량을 monitor
- 메모리 사용량이 특정 임계점 (RAM util >= 90%) 에 도달하면
  - Save 파일 백업
  - 서버 재시작
 
아래 명령으로 Palworld Dedicated Server 를 시작:

```
bash infinitePalServer.sh
```

처음 Palworld Dedicated Server 를 deploy 하는 경우 서버 configuration file 생성을 위해 5초 후 프로세스를 강제 종료합니다.

서버를 다시 시작하면 관리 비밀번호, 서버 비밀번호 (서버 접속에 필요) 입력 후 정상 동작합니다.
