# V2V-and-V2I-task-offloading     
Joint Task Offloading and Resource Allocation for Integrated V2V and V2I Communication

# Introduction
OTA 기술 등장으로 차량에 탑재되는 소프트웨어는 하드웨어 스펙보다 높은 사양을 요구하게 될 수도 있음. 
이 때, 플래투닝 시나리오에서 저성능/고성능 차량이 섞여서 운행할 때 V2V 통신을 활용해 주변 차량으로 offloading하여 저성능 차량의 안정적인 운행을 도모하고자 함. 
저성능/고성능 차량이 함께 주행 중일 때, V2V+V2I 환경과 V2I 환경을 비교함.

# How-to-use
차량과 RSU의 위치 및 스펙, 네트워크 채널 상태를 input으로 입력하면 매 timeslot마다 쌓여있는 task의 양과 에너지 소모량을 고려하여 최적의 Offloading 정책 및 GPU resource allocation 값을 return함. 


# Result
차량 큐 길이 비교
![image](https://github.com/user-attachments/assets/ddd6c81a-c730-457b-aeb8-09ecaa02c815)

V2V가 없는 환경에서는 차량 큐가 발산하는 반면, V2V가 있으면 주변 차량으로 로드를 분산하여 안정적인 차량 큐 길이를 유지함. 

RSU 및 클라우드 큐 길이 비교 
![image](https://github.com/user-attachments/assets/d389b363-b328-4c73-b78c-efcbaec4529a)
V2V가 없는 환경에서는 저성능 차량이 RSU와 클라우드로 많이 오프로딩하여 서버의 큐가 발산하는 모습. 
V2V가 있으면 주변 차량으로 로드를 분산하여 안정적인 서버 큐 길이를 유지할 수 있음. 

에너지 소모량 비교
![image](https://github.com/user-attachments/assets/c84c3377-56fb-4c8c-87ec-6cfa3ec601fb)
고성능 차량에서 사용하는 에너지 소모량이 큰 폭으로 증가함. 
하지만 플래투닝 적용하는 회사 입장에서 새로운 고성능 기기 도입 비용을 줄이고, 기존 차량을 활용할 수 있는 방향으로 적용 가능함. 

 
