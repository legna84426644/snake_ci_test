*** Settings ***
Resource    ../common.robot
Resource    ../commonWeb.robot
Resource    ../commonGit.robot
Resource    ../commonBitbucket.robot
Resource    ../settings.robot
Resource    ../pipelineDetailPage.robot
Resource    ../pipelineListPage.robot
Resource    ../jobListPage.robot

Suite Setup    Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup    Common Test Setup
Test Teardown    Common Test Teardown

Force Tags    basic
Test Timeout    2 minutes
*** Variables ***

*** Test Cases ***
Verify "stages" is required
    ## verify stage is require at pipeline level
    Set Test Variable    ${COMMIT_MSG}    Validate stage is required at pipeline level
    ${url}    Copy File To Repo And Push    ${EXECDIR}/files/yaml_stage_pipeline.yaml    ${SNAKE_YAML}    ${COMMIT_MSG}
    # verify a pipeline
    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
    Verify A Pipeline Detail Page With Error In Yaml File    ${COMMIT_MSG}    Unable to run pipeline due to errors in snake-ci.yaml file    Job "install dependencies": stage field is not specified. No stages defined.    ${pipeline_num}
    Go To Pipeline List Page And Verify A Pipeline    1    Failed    ${COMMIT_MSG}    ${pipeline_num}
    Go To Job List Page And Verify No Job From A Pipeline    ${pipeline_num}
    ## verify stage is require at job level
    Set Test Variable    ${COMMIT_MSG}    Validate stage is required at job level
    ${url}    Copy File To Repo And Push    ${EXECDIR}/files/yaml_stage_job.yaml    ${SNAKE_YAML}    ${COMMIT_MSG}
    # verify a pipeline
    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
    Verify A Pipeline Detail Page With Error In Yaml File    ${COMMIT_MSG}    Unable to run pipeline due to errors in snake-ci.yaml file    Job "install dependencies": stage field is not specified. Should be one of the following:\n* stage1    ${pipeline_num}
    Go To Pipeline List Page And Verify A Pipeline    1    Failed    ${COMMIT_MSG}    ${pipeline_num}
    Go To Job List Page And Verify No Job From A Pipeline    ${pipeline_num}

Verify "image" is optional and default is alpine
    Set Test Variable    ${COMMIT_MSG}    Verify image field
    # verify stage is require
    ${url}    Copy File To Repo And Push    ${EXECDIR}/files/yaml_image.yaml    ${SNAKE_YAML}    ${COMMIT_MSG}
    # verify pipeline detail page
    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
    Verify A Pipeline Detail Page    Completed    ${COMMIT_MSG}    Jobs (3 total):3 completed    ${pipeline_num}
    # Verify jobs in pipeline detail page
    Verify A Job In Pipeline Detail Page    1    Completed    STAGE1    install dependencies    Using docker image: alpine:latest
    Verify A Job In Pipeline Detail Page    2    Completed    STAGE2    unit tests 1    Using docker image: golang:latest
    Verify A Job In Pipeline Detail Page    3    Completed    STAGE2    unit tests 2    Using docker image: maven:3
    # verify pipeline in pipeline list page
    Go To Pipeline List Page And Verify A Pipeline    1    Completed    ${COMMIT_MSG}    ${pipeline_num}
    # verify jobs in the job list page
    Go To Job List Page And Verify A Job    1    Completed    ${COMMIT_MSG}    STAGE1    install dependencies    ${pipeline_num}
    Go To Job List Page And Verify A Job    2    Completed    ${COMMIT_MSG}    STAGE2    unit tests 1    ${pipeline_num}
    Go To Job List Page And Verify A Job    3    Completed    ${COMMIT_MSG}    STAGE2    unit tests 2    ${pipeline_num}

Verify "commands" is required
    Set Test Variable    ${COMMIT_MSG}    Verify command is required
    # verify stage is require
    ${url}    Copy File To Repo And Push    ${EXECDIR}/files/yaml_command.yaml    ${SNAKE_YAML}    ${COMMIT_MSG}
    # verify pipeline detail page
    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
    Verify A Pipeline Detail Page    Completed    ${COMMIT_MSG}    Jobs (1 total):1 completed    ${pipeline_num}
    Verify A Job In Pipeline Detail Page    1    Completed    STAGE1    install dependencies
    Go To Pipeline List Page And Verify A Pipeline    1    Completed    ${COMMIT_MSG}    ${pipeline_num}
    Go To Job List Page And Verify A Job    1    Completed    ${COMMIT_MSG}    STAGE1    install dependencies    ${pipeline_num}

Verify "only" will filter branch or tag
    ### Only will filter branch
    Set Test Variable    ${COMMIT_MSG}    Verify Only with branch1
    Set Test Variable    ${BRANCH_NAME}    branch1
    # delete the branch
    Delete Local And Remote Branch And Ignore Failure    ${BRANCH_NAME}
    # push a new yaml file
    ${url}    Copy File To Repo And Push On A Branch    ${BRANCH_NAME}    ${EXECDIR}/files/yaml_only.yaml    ${SNAKE_YAML}    ${COMMIT_MSG}
    # verify pipeline detail page
    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
    Verify A Pipeline Detail Page    Completed    ${COMMIT_MSG}    Jobs (3 total):3 completed    ${pipeline_num}
    # Verify jobs in pipeline detail page
    Verify A Job In Pipeline Detail Page    1    Completed    STAGE1    job 1
    Verify A Job In Pipeline Detail Page    2    Completed    STAGE2    job 3
    Verify A Job In Pipeline Detail Page    3    Completed    STAGE2    job 4
    # verify pipeline in pipeline list page
    Go To Pipeline List Page And Verify A Pipeline    1    Completed    ${COMMIT_MSG}    ${pipeline_num}
    # verify jobs in the job list page
    Go To Job List Page And Verify A Job    1    Completed    ${COMMIT_MSG}    STAGE1    job 1    ${pipeline_num}
    Go To Job List Page And Verify A Job    2    Completed    ${COMMIT_MSG}    STAGE2    job 3    ${pipeline_num}
    Go To Job List Page And Verify A Job    3    Completed    ${COMMIT_MSG}    STAGE2    job 4    ${pipeline_num}
    ### Only will filter tag
    Set Test Variable    ${COMMIT_MSG}    Verify Only with tag2
    Set Test Variable    ${TAG_NAME}    tag2
    ${url}    Copy File To Repo And Push    ${EXECDIR}/files/yaml_only.yaml    ${SNAKE_YAML}    ${COMMIT_MSG}
    # delete the tag on master
    Delete Local And Remote Tag On A Branch And Ignore Failure    master    ${TAG_NAME}
    # add tag to latest commit on master
    ${url}    Add Tag To Master    ${TAG_NAME}
    # verify pipeline detail page
    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
    Verify A Pipeline Detail Page    Completed    ${commit_msg}    Jobs (2 total):2 completed    ${pipeline_num}
    # Verify jobs in pipeline detail page
    Verify A Job In Pipeline Detail Page    1    Completed    STAGE1    job 2
    Verify A Job In Pipeline Detail Page    2    Completed    STAGE2    job 4
    # verify pipeline in pipeline list page
    Go To Pipeline List Page And Verify A Pipeline    1    Completed    ${commit_msg}    ${pipeline_num}
    # verify jobs in the job list page
    Go To Job List Page And Verify A Job    1    Completed    ${commit_msg}    STAGE1    job 2    ${pipeline_num}
    Go To Job List Page And Verify A Job    2    Completed    ${commit_msg}    STAGE2    job 4    ${pipeline_num}

Verify "only" with variables - Only with job pipeline and dialog variable
    Set Test Variable    ${COMMIT_MSG}    Verify Only with job and pipeline variable
    ${url}    Copy File To Repo And Push    ${EXECDIR}/files/yaml_only_variable.yaml    ${SNAKE_YAML}    ${COMMIT_MSG}
    # verify a pipeline
    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
    Verify A Pipeline Detail Page    Completed    ${COMMIT_MSG}    Jobs (3 total):3 completed    ${pipeline_num}
    # Verify jobs in pipeline detail page
    Verify A Job In Pipeline Detail Page    1    Completed    STAGE1    job 1    echo "job 1"\njob 1
    Verify A Job In Pipeline Detail Page    2    Completed    STAGE1    job 2    echo "job 2"\njob 2
    Verify A Job In Pipeline Detail Page    3    Completed    STAGE2    job 6    echo "job 6"\njob 6
    # verify pipeline in pipeline list page
    Go To Pipeline List Page And Verify A Pipeline    1    Completed    ${COMMIT_MSG}    ${pipeline_num}
    # verify jobs in the job list page
    Go To Job List Page And Verify A Job    1    Completed    ${COMMIT_MSG}    STAGE1    job 1    ${pipeline_num}
    Go To Job List Page And Verify A Job    2    Completed    ${COMMIT_MSG}    STAGE1    job 2    ${pipeline_num}
    Go To Job List Page And Verify A Job    3    Completed    ${COMMIT_MSG}    STAGE2    job 6    ${pipeline_num}
    ## Only with dialog variable
    Invoke A New Pipeline    master    dialog_var    This a dialog var
    # verify pipeline detail page
    ${pipeline_int}    Convert To Integer    ${pipeline_num}
    ${pipeline_num}    Convert To String    ${pipeline_int + 1}
    Verify A Pipeline Detail Page    Completed    ${commit_msg}    Jobs (4 total):4 completed    ${pipeline_num}
    # Verify jobs in pipeline detail page
    Verify A Job In Pipeline Detail Page    1    Completed    STAGE1    job 1    echo "job 1"\njob 1
    Verify A Job In Pipeline Detail Page    2    Completed    STAGE1    job 2    echo "job 2"\njob 2
    Verify A Job In Pipeline Detail Page    3    Completed    STAGE1    job 3    echo "job 3"\njob 3
    Verify A Job In Pipeline Detail Page    4    Completed    STAGE2    job 6    echo "job 6"\njob 6
    # verify pipeline in pipeline list page
    Go To Pipeline List Page And Verify A Pipeline    1    Completed    ${COMMIT_MSG}    ${pipeline_num}
    # verify jobs in the job list page
    Go To Job List Page And Verify A Job    1    Completed    ${COMMIT_MSG}    STAGE1    job 1    ${pipeline_num}
    Go To Job List Page And Verify A Job    2    Completed    ${COMMIT_MSG}    STAGE1    job 2    ${pipeline_num}
    Go To Job List Page And Verify A Job    3    Completed    ${COMMIT_MSG}    STAGE1    job 3    ${pipeline_num}
    Go To Job List Page And Verify A Job    4    Completed    ${COMMIT_MSG}    STAGE2    job 6    ${pipeline_num}


Verify "only" with variables - Only with repo and project variable
    [Setup]    Delete All Variables
    [Teardown]    Delete All Variables
    ## Only with repo variable
    # add repo variable
    Add A Repo Variable    repo_var    This a repo var
    Set Test Variable    ${COMMIT_MSG}    Verify Only with repo and project variable
    ${url}    Copy File To Repo And Push    ${EXECDIR}/files/yaml_only_variable.yaml    ${SNAKE_YAML}    ${COMMIT_MSG}
    # verify a pipeline
    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
    Verify A Pipeline Detail Page    Completed    ${COMMIT_MSG}    Jobs (4 total):4 completed    ${pipeline_num}
    # Verify jobs in pipeline detail page
    Verify A Job In Pipeline Detail Page    1    Completed    STAGE1    job 1    echo "job 1"\njob 1
    Verify A Job In Pipeline Detail Page    2    Completed    STAGE1    job 2    echo "job 2"\njob 2
    Verify A Job In Pipeline Detail Page    3    Completed    STAGE1    job 4    echo "job 4"\njob 4
    Verify A Job In Pipeline Detail Page    4    Completed    STAGE2    job 6    echo "job 6"\njob 6
    # verify pipeline in pipeline list page
    Go To Pipeline List Page And Verify A Pipeline    1    Completed    ${COMMIT_MSG}    ${pipeline_num}
    # verify jobs in the job list page
    Go To Job List Page And Verify A Job    1    Completed    ${COMMIT_MSG}    STAGE1    job 1    ${pipeline_num}
    Go To Job List Page And Verify A Job    2    Completed    ${COMMIT_MSG}    STAGE1    job 2    ${pipeline_num}
    Go To Job List Page And Verify A Job    3    Completed    ${COMMIT_MSG}    STAGE1    job 4    ${pipeline_num}
    Go To Job List Page And Verify A Job    4    Completed    ${COMMIT_MSG}    STAGE2    job 6    ${pipeline_num}
    Delete All Repo Variable
    ## Only with project variable
    # add project variable
    Add A Project Variable    project_var    This a project var
    Invoke A New Pipeline    master    xxx    yyy
    # verify pipeline detail page
    ${pipeline_int}    Convert To Integer    ${pipeline_num}
    ${pipeline_num}    Convert To String    ${pipeline_int + 1}
    Verify A Pipeline Detail Page    Completed    ${commit_msg}    Jobs (4 total):4 completed    ${pipeline_num}
    # Verify jobs in pipeline detail page
    Verify A Job In Pipeline Detail Page    1    Completed    STAGE1    job 1    echo "job 1"\njob 1
    Verify A Job In Pipeline Detail Page    2    Completed    STAGE1    job 2    echo "job 2"\njob 2
    Verify A Job In Pipeline Detail Page    3    Completed    STAGE1    job 5    echo "job 5"\njob 5
    Verify A Job In Pipeline Detail Page    4    Completed    STAGE2    job 6    echo "job 6"\njob 6
    # verify pipeline in pipeline list page
    Go To Pipeline List Page And Verify A Pipeline    1    Completed    ${COMMIT_MSG}    ${pipeline_num}
    # verify jobs in the job list page
    Go To Job List Page And Verify A Job    1    Completed    ${COMMIT_MSG}    STAGE1    job 1    ${pipeline_num}
    Go To Job List Page And Verify A Job    2    Completed    ${COMMIT_MSG}    STAGE1    job 2    ${pipeline_num}
    Go To Job List Page And Verify A Job    3    Completed    ${COMMIT_MSG}    STAGE1    job 5    ${pipeline_num}
    Go To Job List Page And Verify A Job    4    Completed    ${COMMIT_MSG}    STAGE2    job 6    ${pipeline_num}

Verify variable in image field - Image with job pipeline and dialog variable
    Set Test Variable    ${COMMIT_MSG}    Verify Image with job and pipeline variable
    ${url}    Copy File To Repo And Push    ${EXECDIR}/files/yaml_image_variable.yaml    ${SNAKE_YAML}    ${COMMIT_MSG}
    # verify a pipeline
    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
    Verify A Pipeline Detail Page    Failed    ${COMMIT_MSG}    Jobs (6 total):3 failed1 skipped2 completed    ${pipeline_num}
    # Verify jobs in pipeline detail page
    Verify A Job In Pipeline Detail Page    1    Completed    STAGE1    job 1    Using docker image: maven:3
    Verify A Job In Pipeline Detail Page    2    Completed    STAGE1    job 2    Using docker image: alpine:latest
    Verify A Job In Pipeline Detail Page    3    Failed    STAGE1    job 3    unable to pull image ""
    Verify A Job In Pipeline Detail Page    4    Failed    STAGE1    job 4    unable to pull image ""
    Verify A Job In Pipeline Detail Page    5    Failed    STAGE1    job 5    unable to pull image ""
    Verify A Job In Pipeline Detail Page    6    Skipped    STAGE2    job 6
    # verify pipeline in pipeline list page
    Go To Pipeline List Page And Verify A Pipeline    1    Failed    ${COMMIT_MSG}    ${pipeline_num}
    # verify jobs in the job list page
    Go To Job List Page And Verify A Job    1    Completed    ${COMMIT_MSG}    STAGE1    job 1    ${pipeline_num}
    Go To Job List Page And Verify A Job    2    Completed    ${COMMIT_MSG}    STAGE1    job 2    ${pipeline_num}
    Go To Job List Page And Verify A Job    3    Failed    ${COMMIT_MSG}    STAGE1    job 3    ${pipeline_num}
    Go To Job List Page And Verify A Job    4    Failed    ${COMMIT_MSG}    STAGE1    job 4    ${pipeline_num}
    Go To Job List Page And Verify A Job    5    Failed    ${COMMIT_MSG}    STAGE1    job 5    ${pipeline_num}
    Go To Job List Page And Verify A Job    6    Skipped    ${COMMIT_MSG}    STAGE2    job 6    ${pipeline_num}
    ## Only with dialog variable
    Invoke A New Pipeline    master    dialog_var    golang
    # verify pipeline detail page
    ${pipeline_int}    Convert To Integer    ${pipeline_num}
    ${pipeline_num}    Convert To String    ${pipeline_int + 1}
    Verify A Pipeline Detail Page    Failed    ${COMMIT_MSG}    Jobs (6 total):2 failed1 skipped3 completed    ${pipeline_num}
    # Verify jobs in pipeline detail page
    Verify A Job In Pipeline Detail Page    1    Completed    STAGE1    job 1    Using docker image: maven:3
    Verify A Job In Pipeline Detail Page    2    Completed    STAGE1    job 2    Using docker image: alpine:latest
    Verify A Job In Pipeline Detail Page    3    Completed    STAGE1    job 3    Using docker image: golang:latest
    Verify A Job In Pipeline Detail Page    4    Failed    STAGE1    job 4    unable to pull image ""
    Verify A Job In Pipeline Detail Page    5    Failed    STAGE1    job 5    unable to pull image ""
    Verify A Job In Pipeline Detail Page    6    Skipped    STAGE2    job 6
    # verify pipeline in pipeline list page
    Go To Pipeline List Page And Verify A Pipeline    1    Failed    ${COMMIT_MSG}    ${pipeline_num}
    # verify jobs in the job list page
    Go To Job List Page And Verify A Job    1    Completed    ${COMMIT_MSG}    STAGE1    job 1    ${pipeline_num}
    Go To Job List Page And Verify A Job    2    Completed    ${COMMIT_MSG}    STAGE1    job 2    ${pipeline_num}
    Go To Job List Page And Verify A Job    3    Completed    ${COMMIT_MSG}    STAGE1    job 3    ${pipeline_num}
    Go To Job List Page And Verify A Job    4    Failed    ${COMMIT_MSG}    STAGE1    job 4    ${pipeline_num}
    Go To Job List Page And Verify A Job    5    Failed    ${COMMIT_MSG}    STAGE1    job 5    ${pipeline_num}
    Go To Job List Page And Verify A Job    6    Skipped    ${COMMIT_MSG}    STAGE2    job 6    ${pipeline_num}

Verify variable in image field - Image with repo and project variable
    [Setup]    Delete All Variables
    [Teardown]    Delete All Variables
    ## Only with repo variable
    # add repo variable
    Add A Repo Variable    repo_var    golang
    Set Test Variable    ${COMMIT_MSG}    Verify Only with repo and project variable
    ${url}    Copy File To Repo And Push    ${EXECDIR}/files/yaml_image_variable2.yaml    ${SNAKE_YAML}    ${COMMIT_MSG}
    # verify a pipeline
    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
    Verify A Pipeline Detail Page    Failed    ${COMMIT_MSG}    Jobs (3 total):1 failed1 skipped1 completed    ${pipeline_num}
    # Verify jobs in pipeline detail page
    Verify A Job In Pipeline Detail Page    1    Completed    STAGE1    job 1    Using docker image: golang:latest
    Verify A Job In Pipeline Detail Page    2    Failed    STAGE1    job 2    unable to pull image ""
    Verify A Job In Pipeline Detail Page    3    Skipped    STAGE2    job 3
    # verify pipeline in pipeline list page
    Go To Pipeline List Page And Verify A Pipeline    1    Failed    ${COMMIT_MSG}    ${pipeline_num}
    # verify jobs in the job list page
    Go To Job List Page And Verify A Job    1    Completed    ${COMMIT_MSG}    STAGE1    job 1    ${pipeline_num}
    Go To Job List Page And Verify A Job    2    Failed    ${COMMIT_MSG}    STAGE1    job 2    ${pipeline_num}
    Go To Job List Page And Verify A Job    3    Skipped    ${COMMIT_MSG}    STAGE2    job 3    ${pipeline_num}
    Delete All Repo Variable
    ## Only with project variable
    # add project variable
    Add A Project Variable    project_var    maven:3
    Invoke A New Pipeline    master    xxx    yyy
    # verify pipeline detail page
    ${pipeline_int}    Convert To Integer    ${pipeline_num}
    ${pipeline_num}    Convert To String    ${pipeline_int + 1}
    Verify A Pipeline Detail Page    Failed    ${commit_msg}    Jobs (3 total):1 failed1 skipped1 completed    ${pipeline_num}
    # Verify jobs in pipeline detail page
    Verify A Job In Pipeline Detail Page    1    Failed    STAGE1    job 1    unable to pull image ""
    Verify A Job In Pipeline Detail Page    2    Completed    STAGE1    job 2    Using docker image: maven:3
    Verify A Job In Pipeline Detail Page    3    Skipped    STAGE2    job 3
    # verify pipeline in pipeline list page
    Go To Pipeline List Page And Verify A Pipeline    1    Failed    ${COMMIT_MSG}    ${pipeline_num}
    # verify jobs in the job list page
    Go To Job List Page And Verify A Job    1    Failed    ${COMMIT_MSG}    STAGE1    job 1    ${pipeline_num}
    Go To Job List Page And Verify A Job    2    Completed    ${COMMIT_MSG}    STAGE1    job 2    ${pipeline_num}
    Go To Job List Page And Verify A Job    3    Skipped    ${COMMIT_MSG}    STAGE2    job 3    ${pipeline_num}

Verify hidden job
    ## verify stage is require at pipeline level
    Set Test Variable    ${COMMIT_MSG}    Verify hidden job
    ${url}    Copy File To Repo And Push    ${EXECDIR}/files/yaml_hidden_job.yaml    ${SNAKE_YAML}    ${COMMIT_MSG}
    ${pipeline_num}    Go To Pipeline Detail Page    ${url}
    Verify A Pipeline Detail Page    Failed    ${COMMIT_MSG}    Jobs (3 total):1 failed2 completed    ${pipeline_num}
    # Verify jobs in pipeline detail page
    Verify A Job In Pipeline Detail Page    1    Completed    BUILD    build for mac    echo "build for mac"\nbuild for mac
    Verify A Job In Pipeline Detail Page    2    Completed    BUILD    build for linux    echo "build for linux"\nbuild for linux
    Verify A Job In Pipeline Detail Page    3    Failed    BUILD    build for windows    unable to pull image ""
    # verify pipeline in pipeline list page
    Go To Pipeline List Page And Verify A Pipeline    1    Failed    ${COMMIT_MSG}    ${pipeline_num}
    # verify jobs in the job list page
    Go To Job List Page And Verify A Job    1    Completed    ${COMMIT_MSG}    BUILD    build for mac    ${pipeline_num}
    Go To Job List Page And Verify A Job    2    Completed    ${COMMIT_MSG}    BUILD    build for linux    ${pipeline_num}
    Go To Job List Page And Verify A Job    3    Failed    ${COMMIT_MSG}    BUILD    build for windows    ${pipeline_num}

Verify all jobs are filtered by Only
    ## push
    Set Test Variable    ${COMMIT_MSG}    Verify all job filtered by only
    Copy File To Repo And Push Without Pipeline    ${EXECDIR}/files/yaml_only_filter_all.yaml    ${SNAKE_YAML}    ${COMMIT_MSG}
    ## trigger from new pipelie dialog
    Invoke A New Pipeline And Verify Error    master    xxx    yyy    No jobs for the pipeline. The jobs were filtered out by only parameters.

*** Keywords ***
