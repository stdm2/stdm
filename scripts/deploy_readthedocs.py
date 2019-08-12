############################################################################################
# Python script to create a read-the-docs project on a local read-the-docs server
# and set a Git webhook to a local Git server and trigger the build of the documentation
# author: Adam Lang, 2018
# 
# Git issue: https://github.com/rtfd/readthedocs.org/issues/2725
# 
# requirements.txt:
# certifi==2018.4.16
# chardet==3.0.4
# idna==2.7
# pkg-resources==0.0.0
# requests==2.19.1
# urllib3==1.23
############################################################################################

##### Configuration ########################
rtd_project_slug = 'testproject'
rtd_project_name = rtd_project_slug
rtd_server_protocol = 'http'
rtd_server_addr = '192.168.1.106'
rtd_server_port = '8000'
rtd_user = 'adam'
rtd_password = 'secretpassword'
git_server_protocol = 'http'
git_server_addr = '192.168.1.120'
git_repo_path = '/git/testproject.git'
############################################

import requests
import os

''' This function sets up the project on the readthedocs server
Please set the project and the server in the config variables above 
'''
def create_rtd_project(using_curl = False):
    if using_curl == False:
        headers = {   'Content-Type': 'application/json',}
        git_link =  git_server_protocol + '://'+ git_server_addr + git_repo_path
        api_url =  rtd_server_protocol + '://' + rtd_server_addr + ':' +  rtd_server_port + '/api/v2/project/'
        data = '{"repo": "'+git_link+'", "slug": "'+ rtd_project_slug+'", "name": "'+ rtd_project_name+'", "users" :[2]}'
        r = requests.post(api_url, headers = headers, data = data, auth=(rtd_user, rtd_password))
        if r.status_code == 201:
            print("INFO: Project " + rtd_project_slug+" created on readthedocs server")
    else:
        cmd = """curl """+rtd_server_protocol+"""://"""+rtd_server_addr+""":"""+rtd_server_port+     \
                      """/api/v2/project/ -X POST -H "Content-Type: application/json" -d '{"repo": \""""+git_server_protocol+    \
                      """://"""+git_server_addr+git_repo_path+"""\", "slug": \""""+rtd_project_slug+"""\","name":\""""+    \
                      rtd_project_name+"""\","users":[2]}' -u """+rtd_user+""":"""+rtd_password
        os.system(cmd)
        
''' This function creates a git webhook on the readthedocs server and returns the link of the webhook as a string. 
Please set the project and the server in the config variables above 
'''
def set_webhook_on_rtd():
    with requests.session() as s:
        url = rtd_server_protocol + '://' + rtd_server_addr + ':' +  rtd_server_port + '/accounts/login/'
        # fetch the login page
        s.get(url)
        if 'csrftoken' in s.cookies:
            # Django 1.6 and up
            csrftoken = s.cookies['csrftoken']
        else:
            # older versions
            csrftoken = s.cookies['csrf']

        login_data = dict(login= rtd_user, password= rtd_password, csrfmiddlewaretoken=csrftoken, next='/')
        r = s.post(url, data=login_data, headers=dict(Referer=url))
        url =  rtd_server_protocol + '://' + rtd_server_addr + ':' +  rtd_server_port + '/dashboard/' + rtd_project_slug + '/integrations/create/'
        if 'csrftoken' in s.cookies:
            # Django 1.6 and up
            csrftoken = s.cookies['csrftoken']
        else:
            # older versions
            csrftoken = s.cookies['csrf']

        hook_data = dict(integration_type = 'github_webhook', csrfmiddlewaretoken=csrftoken, next='/')
        r = s.post(url, data=hook_data, headers=dict(Referer=url)) 

        if r.status_code == requests.codes.ok:
            print("INFO: Webhook for project "+ rtd_project_slug + " generated on readthedocs server")

        #Extract the webhook_link from the returned html page
        data =  r.text.replace('\n','')
        pos = data.find('>'+rtd_server_addr+':'+rtd_server_port+'/api/v2/webhook/'+ rtd_project_slug+'/')
        link = data[pos+1:].split('<')
        return (rtd_server_protocol + '://' + link[0])

''' This function triggers the build of the project documentation 
'''
def run_build(webhook_link, using_curl = False):
    print("INFO: Running build of documentation...")
    if using_curl == False:
        data = [('ref', 'latest'),]
        r = requests.post(webhook_link, data=data)
        if r.status_code == requests.codes.ok:
            print("INFO: The build of " + rtd_project_slug+" documentation was successful")
    else:
        cmd = 'curl -X POST -d "ref=latest" '+ webhook_link
        os.system(cmd)

if __name__ == "__main__":
    create_rtd_project()
    webhook_link = set_webhook_on_rtd()
    print("INFO: Webhook url: " + webhook_link)
    run_build(webhook_link)
    print("INFO: The Documentation is availible at "+ rtd_server_protocol + "://" + rtd_server_addr + ":" +  rtd_server_port + "/docs/"+ rtd_project_slug +"/en/latest/")