# SO-101 시뮬레이션 설치 및 공유 매뉴얼

작성: 2026-09-28

## 1. 이 매뉴얼로 실행하는 것

Ubuntu 22.04 데스크톱에 ROS 2 Humble이 이미 설치된 사용자를 대상으로 한다.
Python 3.10을 사용하는 Linux PC 기준이며 Windows, WSL, Docker, 원격 서버는 별도 검증하지 않았다.

이 프로그램은 **MuJoCo 물리 엔진 + Python/Tkinter 화면**으로 동작한다.
Gazebo 시뮬레이션이나 ROS 패키지가 아니다. Humble은 재설치하지 않으며,
`colcon build`, `ros2 launch`, LeRobot 설치는 필요하지 않다.
ROS 토픽, TF, MoveIt, ros2_control 연결은 아직 구현되어 있지 않다.

구성은 다음과 같이 구분된다.

| 구성 | 제공 주체 및 역할 |
| --- | --- |
| 로봇 XML, URDF, STL | TheRobotStudio의 공식 SO-ARM100 저장소 내 SO101 모델 |
| run.py, simulator.py 등 | 이번 실습에서 추가한 실행 화면과 제어 코드 |
| 가상 RGB 센서, 바닥, 블록 | 이번 실습에서 추가한 장면 |

**공식 GitHub만 clone하면 현재의 슬라이더/카메라 화면이 생기지 않는다.**
아래 공유 압축파일의 실행 코드도 함께 받아야 한다.

## 2. 준비물

- Ubuntu 22.04 데스크톱, Python 3.10, ROS 2 Humble 설치 완료.
- 패키지를 처음 설치할 때 인터넷 연결과 sudo 권한.
- 로컬 그래픽 로그인 세션. 화면은 고정 크기이므로 1920 x 1080, 100% 배율을 권장한다.
- `so101-sim-share-20260928.tar.gz` 및 같은 이름의 `.sha256` 파일.

실제 로봇, USB 카메라, NVIDIA GPU, CUDA Toolkit은 필요하지 않다.
기본 설정은 Mesa CPU 소프트웨어 렌더링이다. 이 실습 때문에 NVIDIA 드라이버를
설치/제거/업데이트하지 않는다. CPU 성능에 따라 화면이 느릴 수 있다.
MuJoCo의 Python 패키지에는 엔진이 포함된다. 별도 엔진 설치는 필요하지 않다.

## 3. 파일 받기 및 압축 풀기

공유자에게 압축파일과 체크섬 파일을 받아 같은 폴더에 둔다.
두 파일이 있는 폴더를 파일 관리자로 열고 '터미널에서 열기'를 선택한다.
다운로드 폴더가 영어인지 한글인지는 상관없다.

```bash
sha256sum -c so101-sim-share-20260928.tar.gz.sha256
```

`OK` 또는 성공 메시지가 나와야 한다. 실패하면 파일을 다시 전달받는다.
설치 위치는 다운로드 폴더일 필요가 없다. 홈 아래 새 임시 이름의 폴더를 만들어
기존 작업을 덮어쓰지 않고 압축을 푼다.

```bash
INSTALL_DIR=$(mktemp -d "$HOME/so101-practice-XXXXXX")
tar -xzf so101-sim-share-20260928.tar.gz -C "$INSTALL_DIR"
cd "$INSTALL_DIR/so101-sim"
pwd
```

`pwd`에 나온 경로가 앞으로 사용할 작업 폴더다. 이후 명령은 이 폴더에서 실행한다.
압축파일에는 공식 모델과 라이선스가 포함되어 있어 GitHub 모델을 다시 받을 필요는 없다.
Python 라이브러리는 다음 단계에서 별도로 설치한다.

## 4. 시스템 패키지 설치

아래는 받는 사람이 자신의 PC에서 실행하는 명령이다.
ROS 또는 GPU 드라이버 설치 명령이 아니다. apt가 표시하는 변경 목록을 확인하고 진행한다.
예상치 못한 ROS/드라이버 제거가 표시되면 승인하지 말고 중단한다.

```bash
sudo apt update
sudo apt install python3-venv python3-pip python3-tk libegl1 libegl-mesa0 libgl1 libgl1-mesa-dri libglx-mesa0
/usr/bin/python3 --version
```

Ubuntu 22.04의 기본 Python 3.10을 사용한다. Conda나 다른 Python 환경이 활성화되어
있다면 별도 터미널에서 진행한다. ROS 설치는 유지하되 Python 패키지 경로가 섞이지
않도록 아래 명령은 해당 프로세스에서만 `PYTHONPATH`를 제외한다.

## 5. 새 가상환경 만들기

가상환경 `.venv`는 PC마다 새로 만든다. 공유자의 `.venv`를 복사하지 않는다.
다음 단계는 같은 터미널에서 한 줄씩 실행하고 오류가 나면 다음 줄로 진행하지 않는다.

```bash
env -u PYTHONPATH /usr/bin/python3 -m venv .venv
env -u PYTHONPATH .venv/bin/python -m pip install --upgrade pip
env -u PYTHONPATH .venv/bin/python -m pip install -r requirements.txt
env -u PYTHONPATH .venv/bin/python -m pip check
env -u PYTHONPATH .venv/bin/python -c 'import tkinter, mujoco, numpy, PIL; print("MuJoCo:", mujoco.__version__); print("NumPy:", numpy.__version__); print("Pillow:", PIL.__version__)'
```

직접 의존성은 `mujoco==3.14.0`, `numpy==2.2.6`, `Pillow==12.3.0`으로 고정했다.
간접 의존성 전체를 잠근 환경은 아니다. 설치 시 오류가 나면 버전을 임의로 바꾸기보다
전체 오류 메시지와 Python 버전을 공유한다. `sudo pip`는 사용하지 않는다.

## 6. 화면 없이 물리 및 카메라 검증

```bash
env -u PYTHONPATH LIBGL_ALWAYS_SOFTWARE=1 MUJOCO_GL=egl .venv/bin/python verify.py
```

정상 실행 시 JSON 결과가 출력되고 다음 항목을 확인할 수 있다.

- `actuators`: 6
- `cameras`: 2
- `rgb_shape`: [720, 1280, 3]
- `warnings`: 0
- `reset_passed`: true

관절 목표 추종, 손목 카메라 이동, 비어 있지 않은 RGB 영상 및 초기화를 검사한다.
`captures/verification/report.json`과 PNG 이미지가 생성된다.
이 검증은 실물 파지 성공이나 실물 가반하중을 보장하지 않는다.

## 7. 시뮬레이션 화면 실행

로컬 Ubuntu 데스크톱의 터미널에서 실행한다.

```bash
LIBGL_ALWAYS_SOFTWARE=1 bash run.sh
```

다음에 다시 실행할 때는 파일 관리자로 설치된 `so101-sim` 폴더를 열고
'터미널에서 열기'를 선택한 뒤 같은 명령을 입력한다. 가상환경 활성화는 필요하지 않다.
`run.sh`가 `.venv`를 사용하고 실행 프로세스의 ROS `PYTHONPATH`만 제외한다.
다른 터미널의 ROS 환경이나 `.bashrc`는 변경하지 않는다.

자동 동작으로 시작하려면:

```bash
LIBGL_ALWAYS_SOFTWARE=1 bash run.sh --demo
```

자동 동작은 관절을 흔드는 데모이며, 물체를 찾아 잡는 AI가 아니다.
설치 확인용으로 6초 뒤 자동 종료하는 GUI 시험도 가능하다.

```bash
LIBGL_ALWAYS_SOFTWARE=1 bash run.sh --demo --check-controls --duration 6 --capture-on-exit
```

정상 시 `GUI slider and reset callbacks: PASS`, `Stopped cleanly.`가 출력된다.

## 8. 화면 조작

| 화면 및 조작 | 동작 |
| --- | --- |
| 왼쪽 화면 | 전체 관찰 시점. 왼쪽 마우스 드래그로 회전, 휠로 확대/축소 |
| 오른쪽 화면 | 로봇 손목에 부착한 가상 RGB 센서 |
| 슬라이더 6개 | 팔 관절 5개와 집게. 표시 단위는 도 |
| 각도 숫자 | 현재 각도 / 목표 각도 |
| Pause / Space | 물리 진행 일시정지 또는 재개 |
| Demo / D | 자동 동작 켜기/끄기. 슬라이더를 조작하면 Demo가 꺼짐 |
| Reset / R | 로봇과 블록의 위치 및 속도, 시뮬레이션 시간을 초기화. Demo도 꺼짐 |
| Capture RGB / S | 전체 관찰 영상, 손목 영상, 관절 상태 저장 |
| Esc 또는 창 닫기 | 종료 |

키보드 단축키는 시뮬레이션 창에 포커스를 두고 영어 소문자 입력 상태에서 사용한다.
Reset은 Pause 상태를 해제하지 않는다. 초기화 후 움직이지 않으면 Pause를 확인한다.

저장 결과는 `captures/<날짜-시간>/`의 `overview.png`, `wrist_rgb.png`, `state.json`이다.
`overview.png`는 고정된 관찰 카메라 영상으로, 마우스로 돌린 왼쪽 뷰와 다를 수 있다.
기본 저장 해상도는 1280 x 720이며 연속 동영상 녹화 기능은 없다.

## 9. 프로그래밍할 파일

| 파일 | 수정할 내용 |
| --- | --- |
| settings.json | 초기 관절 각도, 카메라 위치/화각/해상도, 미리보기 주기 |
| simulator.py의 demo_targets | Demo에서 시간에 따라 목표 각도를 생성하는 동작 |
| simulator.py의 set_targets | 관절 목표 입력 API. 6개 값, 단위 라디안 |
| run.py | UI 및 시뮬레이션 반복 실행 흐름 |
| build_scene.py | 블록 위치/질량, 바닥, 조명, 추가 가상 카메라 |

슬라이더 조작은 실시간 적용되지만 Python/JSON 파일 수정은 저장 후 종료하고 다시
실행해야 한다. Python 프로그램이므로 `colcon build` 같은 빌드는 하지 않는다.
`generated/scene.xml`은 매 실행마다 재생성되므로 수정 대상으로 사용하지 않는다.
자세 자동 기록/재생, 역기구학, 자동 파지, 재질 인식 AI는 구현되어 있지 않다.

## 10. 문제 해결

### ensurepip 또는 venv 오류

`python3-venv` 설치를 확인하고 시스템 Python 3.10으로 5단계를 다시 진행한다.
기존 `.venv`에 작업이 있다면 삭제하지 말고 먼저 이름을 바꾸어 보관한다.

### No module named tkinter / mujoco

Tkinter는 `sudo apt install python3-tk`로 설치한다.
MuJoCo는 시스템 `python3`가 아니라 `.venv/bin/python`으로 실행해야 한다.
5단계의 패키지 설치가 성공했는지 확인한다.

### no display name / couldn't connect to display

Tkinter 창을 열 수 없는 환경이다. SSH만 연결된 터미널이나 그래픽 세션 없는 서버 대신
Ubuntu에 직접 그래픽 로그인한 터미널에서 실행한다. 화면 없는 6단계 검증과 GUI 실행은 다르다.

### EGL / OpenGL 오류 또는 검은 화면

4단계의 Mesa/EGL 패키지 설치 여부를 확인하고 아래로 물리/영상 검증부터 다시 한다.

```bash
env -u PYTHONPATH LIBGL_ALWAYS_SOFTWARE=1 MUJOCO_GL=egl .venv/bin/python verify.py
```

그래도 실패하면 오류 전체를 공유한다. 이 단계에서 NVIDIA 드라이버 재설치를 시도하지 않는다.

### 창이 화면 밖으로 나감 / 미리보기가 느림

현재 UI는 고정 크기다. 작은 화면이나 높은 배율에서는 일부가 가려질 수 있다.
화면 해상도/배율을 확인한다. CPU 렌더링이 느리면 `settings.json`의 `preview_fps`를
15에서 8 정도로 낮추고 다시 실행한다. 저장 해상도를 바꾸면 기본 720p를 검사하는
`verify.py`의 조건도 함께 조정해야 하므로 처음에는 해상도를 유지한다.

### Official model not found / STL 파일 누락

공유 압축파일 전체가 풀렸는지 확인한다. `run.py`만 복사해서는 동작하지 않는다.
필요한 모델은 `vendor/SO-ARM100/Simulation/SO101/` 안에 있다.
원본 모델만 다시 받아야 할 경우 다음 12절을 따른다.

## 11. 다른 사람에게 전달할 때

전달할 것은 공유 압축파일, 체크섬 파일, 이 매뉴얼이다.
GitHub에 자동 업로드된 상태는 아니므로 파일을 직접 전달하거나 팀 저장소를 별도로 준비한다.

배포본에는 실행 코드, 설정, 공식 모델, 공식 LICENSE/README 및 출처 안내를 포함한다.
`.venv`, Git 이력, 생성된 장면, 촬영 사진, 캡처 결과, 대화 기록, 인증 정보는 넣지 않는다.
원본 모델의 Apache-2.0 라이선스 및 출처 표시는 유지한다.
공식 저장소의 라이선스가 별도 작성한 실행 코드에 자동 적용되는 것은 아니므로,
공개 GitHub 배포 시 자체 코드의 라이선스는 작성자가 별도로 결정한다.

공유 압축파일의 루트 README에는 원래 개발 PC의 실행 경로와 검증 기록이 남아 있다.
새 PC 설치는 그 절대경로 대신 **이 매뉴얼의 경로와 명령을 우선 사용**한다.
기본 렌더링 방식은 현재도 CPU이며 원래 PC의 NVIDIA 설치 여부와 무관하다.

## 12. 공식 GitHub 모델 재취득 (선택)

공유 압축파일에 모델이 포함되어 있으면 건너뛴다.
아래 명령은 `so101-sim` 작업 폴더에서 실행하며 `vendor/SO-ARM100`이 없어야 한다.
이미 폴더가 있다면 덮어쓰거나 지우지 말고 기존 내용부터 확인한다.
Git이 없다면 먼저 `sudo apt install git`을 실행한다.

```bash
mkdir -p vendor
git clone --filter=blob:none --no-checkout https://github.com/TheRobotStudio/SO-ARM100.git vendor/SO-ARM100
git -C vendor/SO-ARM100 sparse-checkout set Simulation/SO101
git -C vendor/SO-ARM100 checkout --detach 5f6d2b876a53a4872e405b991dd925556c9e38a4
git -C vendor/SO-ARM100 rev-parse HEAD
```

마지막 출력은 위 커밋과 같아야 한다. 원본 XML/STL은 변경하지 않는다.
`settings.json`에도 이 커밋을 기록했다. 최신 main으로 임의 교체하면 재현 조건이 달라진다.

## 13. 현재 한계 및 출처

- 대회 경기장이나 실제 용기를 재현한 환경이 아니라 3cm 블록 3개의 연습 장면이다.
- 카메라는 핀홀 RGB만 제공한다. 깊이 카메라, 압축, 노출, 왜곡, 지연은 재현하지 않는다.
- 손목 카메라 모형은 공식 32 x 32 mm 기준이며 실제 대회 카메라와의 위치 보정은 하지 않았다.
- 72도는 수평 화각으로 임시 가정했다. 제공 장비 사양 확인 후 조정해야 한다.
- 설정의 30fps는 카메라 목표 사양이며 실제 30fps 처리 보장이 아니다.
- 모터 힘, 접촉, 집기 성공률, 실제 가반하중은 실물로 별도 검증해야 한다.

공식 모델: https://github.com/TheRobotStudio/SO-ARM100

사용 커밋: `5f6d2b876a53a4872e405b991dd925556c9e38a4`

모델 경로: `Simulation/SO101/so101_new_calib_camera.xml`

MuJoCo Python 설치 문서: https://mujoco.readthedocs.io/en/stable/python.html

ROS 2 Humble Ubuntu 설치 문서: https://docs.ros.org/en/humble/Installation/Ubuntu-Install-Debs.html

Humble은 이 매뉴얼의 전제 조건이지 현재 프로그램의 직접 의존성이 아니다.
