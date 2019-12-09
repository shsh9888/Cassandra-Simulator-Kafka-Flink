import csv
import uuid
import  random
buildings =[]
with open('buildinginfo.csv') as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=',')
    line_count = 0
    for row in csv_reader:
        if line_count == 0:
            print(f'Column names are {", ".join(row)}')
            line_count += 1
        else:
            buildings.append(row)
            line_count +=1

# e9494ddc-7100-4946-9b9c-64835bdb55ba,481019ea-b519-4f48-b684-de69a10deb64,Fan,Categorical,2

devices = ['A_Device', 'B_Device','C_Device','D_Device','E_Device','F_Device','G_Device','H_Device','I_Device','J_Device']
deviceTypes = ['Categorical', 'Digital']


with open('deviceinfo.csv','a') as fd:
    for building in buildings:
        for i in range(5):
            id = str(uuid.uuid1());
            buildingId = building[0];
            device = random.choice(devices)
            floor = str(random.randrange(1, 10));
            deviceType =random.choice(deviceTypes)
            row = id + "," + buildingId + "," + device+ "," + deviceType + "," +floor
            fd.write(row)
            fd.write("\n")