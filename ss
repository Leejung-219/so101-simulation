pwd
ls requirements.txt run.sh

env -u PYTHONPATH /usr/bin/python3 -m venv .venv
env -u PYTHONPATH .venv/bin/python -m pip install --upgrade pip
env -u PYTHONPATH .venv/bin/python -m pip install -r requirements.txt
env -u PYTHONPATH .venv/bin/python -m pip check

env -u PYTHONPATH LIBGL_ALWAYS_SOFTWARE=1 MUJOCO_GL=egl .venv/bin/python verify.py
