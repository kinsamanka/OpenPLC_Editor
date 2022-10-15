import os
import socket
import subprocess
from multiprocessing.connection import Listener
import util.paths as paths


class BoardUploader:
    def __init__(self, logger, address=('localhost', 0), authkey=b'password',
                 timeout=5):
        self.log = logger

        self.address = address
        self.authkey = authkey
        self.timeout = timeout

        self.listener = Listener(address, authkey=authkey)
        self.port = self.listener.address[1]
        self.client = None

        self.cwd = os.path.join(paths.AbsParentDir(__file__), 'builder', 'bin')
        self.cmd = ['conda', 'run', '-n', 'base', 'pythonw', 'gui.py',
                    '--port', str(self.port)]

    def _start_uploader(self):
        self.listener._listener._socket.settimeout(self.timeout)
        self.log.write("Starting Uploader ...\n")

        subprocess.Popen(self.cmd, shell=True, cwd=self.cwd)

        ok = True
        try:
            self.client = self.listener.accept()
        except socket.timeout:
            self.client = None
            self.log.write_error('OpenPLC Uploader failed to start!\n')
            ok = False
        else:
            self.log.write("Uploader Started.\n")
        finally:
            self.listener._listener._socket.settimeout(None)

        return ok

    def upload(self, src):
        if not self.client:
            if not self._start_uploader():
                return False
        elif self.client.poll():
            try:
                _ = self.client.recv()
            except ValueError:
                # uploader is still ok but sending v3 data
                pass
            except EOFError:
                # uploader has terminated, restart
                if not self._start_uploader():
                    return False

        self.client.send({'src': src})
        return True
