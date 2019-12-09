from barnum import gen_data
import uuid
import  random

with open('buildinginfo.csv','a') as fd:
    for i in range(100):
        id = str(uuid.uuid1());
        buildingcity = gen_data.create_city_state_zip()[1];
        lat = str(random.randrange(1, 180));
        log = str(random.randrange(1, 180));
        loc = '"' + lat + "," + log + '"'
        companyName = gen_data.create_company_name()
        row = id + "," + buildingcity + "," + loc + "," + companyName
        fd.write(row)
        fd.write("\n")