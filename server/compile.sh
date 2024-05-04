#컴파일과 서버로 전송

dart compile exe bin/main.dart -o compiled/server.exe
dart compile exe bin/client.dart -o compiled/client.exe

# 서버에 컴파일한 파일 보내기
scp -p -i /home/kimhanil/Downloads/ubuntu.pem compiled/server.exe ubuntu@43.202.45.29:/home/ubuntu/server

# 