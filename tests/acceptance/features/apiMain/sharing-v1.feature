@api
Feature: sharing
	Background:
		Given using API version "1"
		And using old DAV path

	Scenario: Creating a new share with user
		Given user "user0" has been created
		And user "user1" has been created
		When user "user0" sends HTTP method "POST" to API endpoint "/apps/files_sharing/api/v1/shares" with body
			| path      | welcome.txt |
			| shareWith | user1       |
			| shareType | 0           |
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"

	Scenario: Creating a share with a group
		Given user "user0" has been created
		And user "user1" has been created
		And group "sharing-group" has been created
		When user "user0" sends HTTP method "POST" to API endpoint "/apps/files_sharing/api/v1/shares" with body
			| path      | welcome.txt   |
			| shareWith | sharing-group |
			| shareType | 1             |
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"

	Scenario: Creating a new share with user who already received a share through their group
		Given user "user0" has been created
		And user "user1" has been created
		And group "sharing-group" has been created
		And user "user1" has been added to group "sharing-group"
		And user "user0" has shared file "welcome.txt" with group "sharing-group"
		When user "user0" sends HTTP method "POST" to API endpoint "/apps/files_sharing/api/v1/shares" with body
			| path      | welcome.txt |
			| shareWith | user1       |
			| shareType | 0           |
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"

	Scenario: Creating a new public share
		Given user "user0" has been created
		When user "user0" creates a share using the API with settings
			| path      | welcome.txt |
			| shareType | 3           |
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And the last public shared file should be able to be downloaded without a password

	Scenario: Creating a new public share with password
		Given user "user0" has been created
		When user "user0" creates a share using the API with settings
			| path      | welcome.txt |
			| shareType | 3           |
			| password  | publicpw    |
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And the last public shared file should be able to be downloaded with password "publicpw"

	Scenario: Creating a new public share of a folder
		Given user "user0" has been created
		When user "user0" creates a share using the API with settings
			| path         | FOLDER   |
			| shareType    | 3        |
			| password     | publicpw |
			| expireDate   | +3 days  |
			| publicUpload | true     |
			| permissions  | 7        |
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And the share fields of the last share should include
			| id          | A_NUMBER             |
			| permissions | 15                   |
			| expiration  | +3 days              |
			| url         | AN_URL               |
			| token       | A_TOKEN              |
			| mimetype    | httpd/unix-directory |

	Scenario: Creating a new public share with password and adding an expiration date
		Given user "user0" has been created
		And as user "user0"
		When the user creates a share using the API with settings
			| path      | welcome.txt |
			| shareType | 3           |
			| password  | publicpw    |
		And the user updates the last share using the API with
			| expireDate | +3 days |
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And the last public shared file should be able to be downloaded with password "publicpw"

	Scenario: Creating a new public share, updating its expiration date and getting its info
		Given user "user0" has been created
		And as user "user0"
		When the user creates a share using the API with settings
			| path      | FOLDER |
			| shareType | 3      |
		And the user updates the last share using the API with
			| expireDate | +3 days |
		And the user gets the info of the last share using the API
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And the share fields of the last share should include
			| id                | A_NUMBER             |
			| item_type         | folder               |
			| item_source       | A_NUMBER             |
			| share_type        | 3                    |
			| file_source       | A_NUMBER             |
			| file_target       | /FOLDER              |
			| permissions       | 1                    |
			| stime             | A_NUMBER             |
			| expiration        | +3 days              |
			| token             | A_TOKEN              |
			| storage           | A_NUMBER             |
			| mail_send         | 0                    |
			| uid_owner         | user0                |
			| storage_id        | home::user0          |
			| file_parent       | A_NUMBER             |
			| displayname_owner | user0                |
			| url               | AN_URL               |
			| mimetype          | httpd/unix-directory |

	Scenario: Creating a new public share, updating its password and getting its info
		Given user "user0" has been created
		And as user "user0"
		When the user creates a share using the API with settings
			| path      | FOLDER |
			| shareType | 3      |
		And the user updates the last share using the API with
			| password | publicpw |
		And the user gets the info of the last share using the API
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And the share fields of the last share should include
			| id                | A_NUMBER             |
			| item_type         | folder               |
			| item_source       | A_NUMBER             |
			| share_type        | 3                    |
			| file_source       | A_NUMBER             |
			| file_target       | /FOLDER              |
			| permissions       | 1                    |
			| stime             | A_NUMBER             |
			| token             | A_TOKEN              |
			| storage           | A_NUMBER             |
			| mail_send         | 0                    |
			| uid_owner         | user0                |
			| storage_id        | home::user0          |
			| file_parent       | A_NUMBER             |
			| displayname_owner | user0                |
			| url               | AN_URL               |
			| mimetype          | httpd/unix-directory |

	Scenario: Creating a new public share, updating its permissions and getting its info
		Given user "user0" has been created
		And as user "user0"
		When the user creates a share using the API with settings
			| path      | FOLDER |
			| shareType | 3      |
		And the user updates the last share using the API with
			| permissions | 7 |
		And the user gets the info of the last share using the API
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And the share fields of the last share should include
			| id                | A_NUMBER             |
			| item_type         | folder               |
			| item_source       | A_NUMBER             |
			| share_type        | 3                    |
			| file_source       | A_NUMBER             |
			| file_target       | /FOLDER              |
			| permissions       | 15                   |
			| stime             | A_NUMBER             |
			| token             | A_TOKEN              |
			| storage           | A_NUMBER             |
			| mail_send         | 0                    |
			| uid_owner         | user0                |
			| storage_id        | home::user0          |
			| file_parent       | A_NUMBER             |
			| displayname_owner | user0                |
			| url               | AN_URL               |
			| mimetype          | httpd/unix-directory |

	Scenario: Creating a new public share, updating publicUpload option and getting its info
		Given user "user0" has been created
		And as user "user0"
		When the user creates a share using the API with settings
			| path      | FOLDER |
			| shareType | 3      |
		And the user updates the last share using the API with
			| publicUpload | true |
		And the user gets the info of the last share using the API
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And the share fields of the last share should include
			| id                | A_NUMBER             |
			| item_type         | folder               |
			| item_source       | A_NUMBER             |
			| share_type        | 3                    |
			| file_source       | A_NUMBER             |
			| file_target       | /FOLDER              |
			| permissions       | 15                   |
			| stime             | A_NUMBER             |
			| token             | A_TOKEN              |
			| storage           | A_NUMBER             |
			| mail_send         | 0                    |
			| uid_owner         | user0                |
			| storage_id        | home::user0          |
			| file_parent       | A_NUMBER             |
			| displayname_owner | user0                |
			| url               | AN_URL               |
			| mimetype          | httpd/unix-directory |

	Scenario: Uploading to a public upload-only share
		Given user "user0" has been created
		And as user "user0"
		And the user has created a share with settings
			| path        | FOLDER |
			| shareType   | 3      |
			| permissions | 4      |
		And the public has uploaded file "test.txt" with content "test"
		When the user downloads the file "/FOLDER/test.txt" using the API
		Then the downloaded content should be "test"

	Scenario: Uploading to a public upload-only share with password
		Given user "user0" has been created
		And as user "user0"
		And the user has created a share with settings
			| path        | FOLDER   |
			| shareType   | 3        |
			| password    | publicpw |
			| permissions | 4        |
		And the public has uploaded file "test.txt" with password "publicpw" and content "test"
		When the user downloads the file "/FOLDER/test.txt" using the API
		Then the downloaded content should be "test"

	Scenario: Downloading from upload-only share is forbidden
		Given user "user0" has been created
		And user "user0" has moved file "/textfile0.txt" to "/FOLDER/test.txt"
		When user "user0" creates a share using the API with settings
			| path        | FOLDER |
			| shareType   | 3      |
			| permissions | 4      |
		Then the public shared file "test.txt" should not be able to be downloaded
		And the HTTP status code should be "404"

	Scenario: Uploading same file to a public upload-only share multiple times
		Given user "user0" has been created
		And as user "user0"
		And the user has created a share with settings
			| path        | FOLDER |
			| shareType   | 3      |
			| permissions | 4      |
		And the public has uploaded file "test.txt" with content "test"
		And the public has uploaded file "test.txt" with content "test2" with autorename mode
		When the user downloads the file "/FOLDER/test.txt" using the API
		Then the downloaded content should be "test"
		And the user downloads the file "/FOLDER/test (2).txt" using the API
		And the downloaded content should be "test2"

	Scenario: Uploading file to a public upload-only share that was deleted does not work
		Given user "user0" has been created
		And user "user0" has created a share with settings
			| path        | FOLDER |
			| shareType   | 3      |
			| permissions | 4      |
		When user "user0" deletes file "/FOLDER" using the API
		Then publicly uploading a file should not work
		And the HTTP status code should be "404"

	Scenario: Uploading file to a public read-only share does not work
		Given user "user0" has been created
		When user "user0" creates a share using the API with settings
			| path        | FOLDER |
			| shareType   | 3      |
			| permissions | 1      |
		Then publicly uploading a file should not work
		And the HTTP status code should be "403"

	Scenario: getting all shares of a user using that user
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has moved file "/textfile0.txt" to "/file_to_share.txt"
		And user "user0" has shared file "file_to_share.txt" with user "user1"
		When user "user0" sends HTTP method "GET" to API endpoint "/apps/files_sharing/api/v1/shares"
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And file "file_to_share.txt" should be included in the response

	Scenario: getting all shares of a user using another user
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has shared file "textfile0.txt" with user "user1"
		When user "admin" sends HTTP method "GET" to API endpoint "/apps/files_sharing/api/v1/shares"
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And file "textfile0.txt" should not be included in the response

	Scenario: getting all shares of a file
		Given user "user0" has been created
		And user "user1" has been created
		And user "user2" has been created
		And user "user3" has been created
		And user "user0" has shared file "textfile0.txt" with user "user1"
		And user "user0" has shared file "textfile0.txt" with user "user2"
		When user "user0" sends HTTP method "GET" to API endpoint "/apps/files_sharing/api/v1/shares?path=textfile0.txt"
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And user "user1" should be included in the response
		And user "user2" should be included in the response
		And user "user3" should not be included in the response

	Scenario: getting all shares of a file with reshares
		Given user "user0" has been created
		And user "user1" has been created
		And user "user2" has been created
		And user "user3" has been created
		And user "user0" has shared file "textfile0.txt" with user "user1"
		And user "user1" has shared file "textfile0 (2).txt" with user "user2"
		When user "user0" sends HTTP method "GET" to API endpoint "/apps/files_sharing/api/v1/shares?reshares=true&path=textfile0.txt"
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And user "user1" should be included in the response
		And user "user2" should be included in the response
		And user "user3" should not be included in the response

	Scenario: Reshared files can be still accessed if a user in the middle removes it.
		Given user "user0" has been created
		And user "user1" has been created
		And user "user2" has been created
		And user "user3" has been created
		And user "user0" has shared file "textfile0.txt" with user "user1"
		And user "user1" has moved file "/textfile0 (2).txt" to "/textfile0_shared.txt"
		And user "user1" has shared file "textfile0_shared.txt" with user "user2"
		And user "user2" has shared file "textfile0_shared.txt" with user "user3"
		When user "user1" deletes file "/textfile0_shared.txt" using the API
		And user "user3" downloads file "/textfile0_shared.txt" with range "bytes=1-7" using the API
		Then the downloaded content should be "wnCloud"

	Scenario: getting share info of a share
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has moved file "/textfile0.txt" to "/file_to_share.txt"
		And user "user0" has shared file "file_to_share.txt" with user "user1"
		When user "user0" gets the info of the last share using the API
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And the share fields of the last share should include
			| id                     | A_NUMBER           |
			| item_type              | file               |
			| item_source            | A_NUMBER           |
			| share_type             | 0                  |
			| share_with             | user1              |
			| file_source            | A_NUMBER           |
			| file_target            | /file_to_share.txt |
			| path                   | /file_to_share.txt |
			| permissions            | 19                 |
			| stime                  | A_NUMBER           |
			| storage                | A_NUMBER           |
			| mail_send              | 0                  |
			| uid_owner              | user0              |
			| storage_id             | home::user0        |
			| file_parent            | A_NUMBER           |
			| share_with_displayname | user1              |
			| displayname_owner      | user0              |
			| mimetype               | text/plain         |

	Scenario: keep group permissions in sync
		Given user "user0" has been created
		And user "user1" has been created
		And group "group1" has been created
		And user "user1" has been added to group "group1"
		And user "user0" has shared file "textfile0.txt" with group "group1"
		And user "user1" has moved file "/textfile0 (2).txt" to "/FOLDER/textfile0.txt"
		And as user "user0"
		When the user updates the last share using the API with
			| permissions | 1 |
		And the user gets the info of the last share using the API
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And the share fields of the last share should include
			| id                | A_NUMBER       |
			| item_type         | file           |
			| item_source       | A_NUMBER       |
			| share_type        | 1              |
			| file_source       | A_NUMBER       |
			| file_target       | /textfile0.txt |
			| permissions       | 1              |
			| stime             | A_NUMBER       |
			| storage           | A_NUMBER       |
			| mail_send         | 0              |
			| uid_owner         | user0          |
			| storage_id        | home::user0    |
			| file_parent       | A_NUMBER       |
			| displayname_owner | user0          |
			| mimetype          | text/plain     |

	Scenario: Sharee can see the share
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has shared file "textfile0.txt" with user "user1"
		When user "user1" sends HTTP method "GET" to API endpoint "/apps/files_sharing/api/v1/shares?shared_with_me=true"
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And the last share_id should be included in the response

	Scenario: Sharee can see the filtered share
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has shared file "textfile0.txt" with user "user1"
		And user "user0" has shared file "textfile1.txt" with user "user1"
		When user "user1" sends HTTP method "GET" to API endpoint "/apps/files_sharing/api/v1/shares?shared_with_me=true&path=textfile1 (2).txt"
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And the last share_id should be included in the response

	Scenario: Sharee can't see the share that is filtered out
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has shared file "textfile0.txt" with user "user1"
		And user "user0" has shared file "textfile1.txt" with user "user1"
		When user "user1" sends HTTP method "GET" to API endpoint "/apps/files_sharing/api/v1/shares?shared_with_me=true&path=textfile0 (2).txt"
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And the last share_id should not be included in the response

	Scenario: Sharee can see the group share
		Given user "user0" has been created
		And user "user1" has been created
		And group "group0" has been created
		And user "user1" has been added to group "group0"
		And user "user0" has shared file "textfile0.txt" with group "group0"
		When user "user1" sends HTTP method "GET" to API endpoint "/apps/files_sharing/api/v1/shares?shared_with_me=true"
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And the last share_id should be included in the response

	Scenario: User is not allowed to reshare file
		Given user "user0" has been created
		And user "user1" has been created
		And user "user2" has been created
		And user "user0" has created a share with settings
			| path        | /textfile0.txt |
			| shareType   | 0              |
			| shareWith   | user1          |
			| permissions | 8              |
		When user "user1" creates a share using the API with settings
			| path        | /textfile0 (2).txt |
			| shareType   | 0                  |
			| shareWith   | user2              |
			| permissions | 31                 |
		Then the OCS status code should be "404"
		And the HTTP status code should be "200"

	Scenario: User is not allowed to reshare file with more permissions
		Given user "user0" has been created
		And user "user1" has been created
		And user "user2" has been created
		And user "user0" has created a share with settings
			| path        | /textfile0.txt |
			| shareType   | 0              |
			| shareWith   | user1          |
			| permissions | 16             |
		When user "user1" creates a share using the API with settings
			| path        | /textfile0 (2).txt |
			| shareType   | 0                  |
			| shareWith   | user2              |
			| permissions | 31                 |
		Then the OCS status code should be "404"
		And the HTTP status code should be "200"

	Scenario: Get a share with a user that didn't receive the share
		Given user "user0" has been created
		And user "user1" has been created
		And user "user2" has been created
		And user "user0" has shared file "textfile0.txt" with user "user1"
		When user "user2" gets the info of the last share using the API
		Then the OCS status code should be "404"
		And the HTTP status code should be "200"

	Scenario: Share of folder and sub-folder to same user - core#20645
		Given user "user0" has been created
		And user "user1" has been created
		And group "group0" has been created
		And user "user1" has been added to group "group0"
		When user "user0" shares file "/PARENT" with user "user1" using the API
		And user "user0" shares file "/PARENT/CHILD" with group "group0" using the API
		Then user "user1" should see the following elements
			| /FOLDER/                 |
			| /PARENT/                 |
			| /PARENT/parent.txt       |
			| /PARENT%20(2)/           |
			| /PARENT%20(2)/parent.txt |
			| /CHILD/                  |
			| /CHILD/child.txt         |
		And the HTTP status code should be "200"

	Scenario: Share a file by multiple channels and download from sub-folder and direct file share
		Given user "user0" has been created
		And user "user1" has been created
		And user "user2" has been created
		And group "group0" has been created
		And user "user1" has been added to group "group0"
		And user "user2" has been added to group "group0"
		And user "user0" has created a folder "/common"
		And user "user0" has created a folder "/common/sub"
		And user "user0" has shared folder "common" with group "group0"
		And user "user1" has shared file "textfile0.txt" with user "user2"
		And user "user1" has moved file "/textfile0.txt" to "/common/textfile0.txt"
		And user "user1" has moved file "/common/textfile0.txt" to "/common/sub/textfile0.txt"
		And user "user2" uploads file "data/file_to_overwrite.txt" to "/textfile0 (2).txt" using the API
		When user "user2" downloads file "/common/sub/textfile0.txt" with range "bytes=0-8" using the API
		Then the downloaded content should be "BLABLABLA"
		And the downloaded content when downloading file "/textfile0 (2).txt" for user "user2" with range "bytes=0-8" should be "BLABLABLA"
		And user "user2" should see the following elements
			| /common/sub/textfile0.txt |
			| /textfile0%20(2).txt      |

	Scenario: Delete all group shares
		Given user "user0" has been created
		And user "user1" has been created
		And group "group1" has been created
		And user "user1" has been added to group "group1"
		And user "user0" has shared file "textfile0.txt" with group "group1"
		And user "user1" has moved file "/textfile0 (2).txt" to "/FOLDER/textfile0.txt"
		When user "user0" deletes the last share using the API
		And user "user1" sends HTTP method "GET" to API endpoint "/apps/files_sharing/api/v1/shares?shared_with_me=true"
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And the last share_id should not be included in the response

	Scenario: delete a share
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has shared file "textfile0.txt" with user "user1"
		When user "user0" deletes the last share using the API
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"

	Scenario: Keep usergroup shares (#22143)
		Given user "user0" has been created
		And user "user1" has been created
		And user "user2" has been created
		And group "group" has been created
		And user "user1" has been added to group "group"
		And user "user2" has been added to group "group"
		And user "user0" has created a folder "/TMP"
		When user "user0" shares file "TMP" with group "group" using the API
		And user "user1" creates a folder "/myFOLDER" using the API
		And user "user1" moves file "/TMP" to "/myFOLDER/myTMP" using the API
		And the administrator deletes user "user2" using the API
		Then user "user1" should see the following elements
			| /myFOLDER/myTMP/ |

	Scenario: Check quota of owners parent directory of a shared file
		Given using old DAV path
		And user "user0" has been created
		And user "user1" has been created
		And the quota of user "user1" has been set to "0"
		And user "user0" has moved file "/welcome.txt" to "/myfile.txt"
		And user "user0" has shared file "myfile.txt" with user "user1"
		When user "user1" uploads file "data/textfile.txt" to "/myfile.txt" using the API
		Then the HTTP status code should be "204"

	Scenario: Don't allow sharing of the root
		Given user "user0" has been created
		When user "user0" creates a share using the API with settings
			| path      | / |
			| shareType | 3 |
		Then the OCS status code should be "403"

	Scenario: Allow modification of reshare
		Given user "user0" has been created
		And user "user1" has been created
		And user "user2" has been created
		And user "user0" has created a folder "/TMP"
		And user "user0" has shared file "TMP" with user "user1"
		And user "user1" has shared file "TMP" with user "user2"
		When user "user1" updates the last share using the API with
			| permissions | 1 |
		Then the OCS status code should be "100"

	Scenario: Do not allow reshare to exceed permissions
		Given user "user0" has been created
		And user "user1" has been created
		And user "user2" has been created
		And user "user0" has created a folder "/TMP"
		And user "user0" has created a share with settings
			| path        | /TMP  |
			| shareType   | 0     |
			| shareWith   | user1 |
			| permissions | 21    |
		And as user "user1"
		And the user has created a share with settings
			| path        | /TMP  |
			| shareType   | 0     |
			| shareWith   | user2 |
			| permissions | 21    |
		When the user updates the last share using the API with
			| permissions | 31 |
		Then the OCS status code should be "404"

	Scenario: Only allow 1 link share per file/folder
		Given user "user0" has been created
		And as user "user0"
		And the user has created a share with settings
			| path      | welcome.txt |
			| shareType | 3           |
		And the last share id has been remembered
		When the user creates a share using the API with settings
			| path      | welcome.txt |
			| shareType | 3           |
		Then the share ids should match

	Scenario: Correct webdav share-permissions for owned file
		Given user "user0" has been created
		And user "user0" has uploaded file with content "foo" to "/tmp.txt"
		When user "user0" gets the following properties of folder "/tmp.txt" using the API
			|{http://open-collaboration-services.org/ns}share-permissions |
		Then the single response should contain a property "{http://open-collaboration-services.org/ns}share-permissions" with value "19"

	Scenario: Correct webdav share-permissions for received file with edit and reshare permissions
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has uploaded file with content "foo" to "/tmp.txt"
		And user "user0" has shared file "/tmp.txt" with user "user1"
		When user "user1" gets the following properties of folder "/tmp.txt" using the API
			|{http://open-collaboration-services.org/ns}share-permissions |
		Then the single response should contain a property "{http://open-collaboration-services.org/ns}share-permissions" with value "19"

	Scenario: Correct webdav share-permissions for received file with edit permissions but no reshare permissions
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has uploaded file with content "foo" to "/tmp.txt"
		And user "user0" has shared file "tmp.txt" with user "user1"
		When user "user0" updates the last share using the API with
			| permissions | 3 |
		And user "user1" gets the following properties of folder "/tmp.txt" using the API
			|{http://open-collaboration-services.org/ns}share-permissions |
		Then the single response should contain a property "{http://open-collaboration-services.org/ns}share-permissions" with value "3"

	Scenario: Correct webdav share-permissions for received file with reshare permissions but no edit permissions
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has uploaded file with content "foo" to "/tmp.txt"
		And user "user0" has shared file "tmp.txt" with user "user1"
		When user "user0" updates the last share using the API with
			| permissions | 17 |
		And user "user1" gets the following properties of folder "/tmp.txt" using the API
			|{http://open-collaboration-services.org/ns}share-permissions |
		Then the single response should contain a property "{http://open-collaboration-services.org/ns}share-permissions" with value "17"

	Scenario: Correct webdav share-permissions for owned folder
		Given user "user0" has been created
		And user "user0" has created a folder "/tmp"
		When user "user0" gets the following properties of folder "/" using the API
			|{http://open-collaboration-services.org/ns}share-permissions |
		Then the single response should contain a property "{http://open-collaboration-services.org/ns}share-permissions" with value "31"

	Scenario: Correct webdav share-permissions for received folder with all permissions
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has created a folder "/tmp"
		And user "user0" has shared file "/tmp" with user "user1"
		When user "user1" gets the following properties of folder "/tmp" using the API
			|{http://open-collaboration-services.org/ns}share-permissions |
		Then the single response should contain a property "{http://open-collaboration-services.org/ns}share-permissions" with value "31"

	Scenario: Correct webdav share-permissions for received folder with all permissions but edit
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has created a folder "/tmp"
		And user "user0" has shared file "/tmp" with user "user1"
		When user "user0" updates the last share using the API with
			| permissions | 29 |
		And user "user1" gets the following properties of folder "/tmp" using the API
			|{http://open-collaboration-services.org/ns}share-permissions |
		Then the single response should contain a property "{http://open-collaboration-services.org/ns}share-permissions" with value "29"

	Scenario: Correct webdav share-permissions for received folder with all permissions but create
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has created a folder "/tmp"
		And user "user0" has shared file "/tmp" with user "user1"
		When user "user0" updates the last share using the API with
			| permissions | 27 |
		And user "user1" gets the following properties of folder "/tmp" using the API
			|{http://open-collaboration-services.org/ns}share-permissions |
		Then the single response should contain a property "{http://open-collaboration-services.org/ns}share-permissions" with value "27"

	Scenario: Correct webdav share-permissions for received folder with all permissions but delete
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has created a folder "/tmp"
		And user "user0" has shared file "/tmp" with user "user1"
		When user "user0" updates the last share using the API with
			| permissions | 23 |
		And user "user1" gets the following properties of folder "/tmp" using the API
			|{http://open-collaboration-services.org/ns}share-permissions |
		Then the single response should contain a property "{http://open-collaboration-services.org/ns}share-permissions" with value "23"

	Scenario: Correct webdav share-permissions for received folder with all permissions but share
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has created a folder "/tmp"
		And user "user0" has shared file "/tmp" with user "user1"
		When user "user0" updates the last share using the API with
			| permissions | 15 |
		And user "user1" gets the following properties of folder "/tmp" using the API
			|{http://open-collaboration-services.org/ns}share-permissions |
		Then the single response should contain a property "{http://open-collaboration-services.org/ns}share-permissions" with value "15"

	Scenario: unique target names for incoming shares
		Given user "user0" has been created
		And user "user1" has been created
		And user "user2" has been created
		And user "user0" has created a folder "/foo"
		And user "user1" has created a folder "/foo"
		When user "user0" shares file "/foo" with user "user2" using the API
		And user "user1" shares file "/foo" with user "user2" using the API
		Then user "user2" should see the following elements
			| /foo/       |
			| /foo%20(2)/ |

	Scenario: Creating a new share with a disabled user
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has been disabled
		When user "user0" sends HTTP method "POST" to API endpoint "/apps/files_sharing/api/v1/shares" with body
			| path      | welcome.txt |
			| shareWith | user1       |
			| shareType | 0           |
		Then the OCS status code should be "997"
		And the HTTP status code should be "401"

	Scenario: Merging shares for recipient when shared from outside with group and member
		Given using old DAV path
		And user "user0" has been created
		And user "user1" has been created
		And group "group1" has been created
		And user "user1" has been added to group "group1"
		And user "user0" has created a folder "/merge-test-outside"
		When user "user0" shares folder "/merge-test-outside" with group "group1" using the API
		And user "user0" shares folder "/merge-test-outside" with user "user1" using the API
		Then as "user1" the folder "/merge-test-outside" should exist
		And as "user1" the folder "/merge-test-outside (2)" should not exist

	Scenario: Merging shares for recipient when shared from outside with group and member with different permissions
		Given user "user0" has been created
		And user "user1" has been created
		And group "group1" has been created
		And user "user1" has been added to group "group1"
		And user "user0" has created a folder "/merge-test-outside-perms"
		When user "user0" shares folder "/merge-test-outside-perms" with group "group1" with permissions 1 using the API
		And user "user0" shares folder "/merge-test-outside-perms" with user "user1" with permissions 31 using the API
		And user "user1" gets the following properties of folder "/merge-test-outside-perms" using the API
			|{http://owncloud.org/ns}permissions|
		Then the single response should contain a property "{http://owncloud.org/ns}permissions" with value "SRDNVCK"
		And as "user1" the folder "/merge-test-outside-perms (2)" should not exist

	Scenario: Merging shares for recipient when shared from outside with two groups
		Given user "user0" has been created
		And user "user1" has been created
		And group "group1" has been created
		And group "group2" has been created
		And user "user1" has been added to group "group1"
		And user "user1" has been added to group "group2"
		And user "user0" has created a folder "/merge-test-outside-twogroups"
		When user "user0" shares folder "/merge-test-outside-twogroups" with group "group1" using the API
		And user "user0" shares folder "/merge-test-outside-twogroups" with group "group2" using the API
		Then as "user1" the folder "/merge-test-outside-twogroups" should exist
		And as "user1" the folder "/merge-test-outside-twogroups (2)" should not exist

	Scenario: Merging shares for recipient when shared from outside with two groups with different permissions
		Given user "user0" has been created
		And user "user1" has been created
		And group "group1" has been created
		And group "group2" has been created
		And user "user1" has been added to group "group1"
		And user "user1" has been added to group "group2"
		And user "user0" has created a folder "/merge-test-outside-twogroups-perms"
		When user "user0" shares folder "/merge-test-outside-twogroups-perms" with group "group1" with permissions 1 using the API
		And user "user0" shares folder "/merge-test-outside-twogroups-perms" with group "group2" with permissions 31 using the API
		And user "user1" gets the following properties of folder "/merge-test-outside-twogroups-perms" using the API
			|{http://owncloud.org/ns}permissions|
		Then the single response should contain a property "{http://owncloud.org/ns}permissions" with value "SRDNVCK"
		And as "user1" the folder "/merge-test-outside-twogroups-perms (2)" should not exist

	Scenario: Merging shares for recipient when shared from outside with two groups and member
		Given user "user0" has been created
		And user "user1" has been created
		And group "group1" has been created
		And group "group2" has been created
		And user "user1" has been added to group "group1"
		And user "user1" has been added to group "group2"
		And user "user0" has created a folder "/merge-test-outside-twogroups-member-perms"
		When user "user0" shares folder "/merge-test-outside-twogroups-member-perms" with group "group1" with permissions 1 using the API
		And user "user0" shares folder "/merge-test-outside-twogroups-member-perms" with group "group2" with permissions 31 using the API
		And user "user0" shares folder "/merge-test-outside-twogroups-member-perms" with user "user1" with permissions 1 using the API
		And user "user1" gets the following properties of folder "/merge-test-outside-twogroups-member-perms" using the API
			|{http://owncloud.org/ns}permissions|
		Then the single response should contain a property "{http://owncloud.org/ns}permissions" with value "SRDNVCK"
		And as "user1" the folder "/merge-test-outside-twogroups-member-perms (2)" should not exist

	Scenario: Merging shares for recipient when shared from inside with group
		Given user "user0" has been created
		And group "group1" has been created
		And user "user0" has been added to group "group1"
		And user "user0" has created a folder "/merge-test-inside-group"
		When user "user0" shares folder "/merge-test-inside-group" with group "group1" using the API
		Then as "user0" the folder "/merge-test-inside-group" should exist
		And as "user0" the folder "/merge-test-inside-group (2)" should not exist

	Scenario: Merging shares for recipient when shared from inside with two groups
		Given user "user0" has been created
		And group "group1" has been created
		And group "group2" has been created
		And user "user0" has been added to group "group1"
		And user "user0" has been added to group "group2"
		And user "user0" has created a folder "/merge-test-inside-twogroups"
		When user "user0" shares folder "/merge-test-inside-twogroups" with group "group1" using the API
		And user "user0" shares folder "/merge-test-inside-twogroups" with group "group2" using the API
		Then as "user0" the folder "/merge-test-inside-twogroups" should exist
		And as "user0" the folder "/merge-test-inside-twogroups (2)" should not exist
		And as "user0" the folder "/merge-test-inside-twogroups (3)" should not exist

	Scenario: Merging shares for recipient when shared from inside with group with less permissions
		Given user "user0" has been created
		And group "group1" has been created
		And group "group2" has been created
		And user "user0" has been added to group "group1"
		And user "user0" has been added to group "group2"
		And user "user0" has created a folder "/merge-test-inside-twogroups-perms"
		When user "user0" shares folder "/merge-test-inside-twogroups-perms" with group "group1" using the API
		And user "user0" shares folder "/merge-test-inside-twogroups-perms" with group "group2" using the API
		And user "user0" gets the following properties of folder "/merge-test-inside-twogroups-perms" using the API
			|{http://owncloud.org/ns}permissions|
		Then the single response should contain a property "{http://owncloud.org/ns}permissions" with value "RDNVCK"
		And as "user0" the folder "/merge-test-inside-twogroups-perms (2)" should not exist
		And as "user0" the folder "/merge-test-inside-twogroups-perms (3)" should not exist

	@skip @issue-29016
	Scenario: Merging shares for recipient when shared from outside with group then user and recipient renames in between
		Given user "user0" has been created
		And user "user1" has been created
		And group "group1" has been created
		And user "user1" has been added to group "group1"
		And user "user0" has created a folder "/merge-test-outside-groups-renamebeforesecondshare"
		When user "user0" shares folder "/merge-test-outside-groups-renamebeforesecondshare" with group "group1" using the API
		And user "user1" moves folder "/merge-test-outside-groups-renamebeforesecondshare" to "/merge-test-outside-groups-renamebeforesecondshare-renamed" using the API
		And user "user0" shares folder "/merge-test-outside-groups-renamebeforesecondshare" with user "user1" using the API
		And user "user1" gets the following properties of folder "/merge-test-outside-groups-renamebeforesecondshare-renamed" using the API
			|{http://owncloud.org/ns}permissions|
		Then the single response should contain a property "{http://owncloud.org/ns}permissions" with value "SRDNVCK"
		And as "user1" the folder "/merge-test-outside-groups-renamebeforesecondshare" should not exist

	Scenario: Merging shares for recipient when shared from outside with user then group and recipient renames in between
		Given user "user0" has been created
		And user "user1" has been created
		And group "group1" has been created
		And user "user1" has been added to group "group1"
		And user "user0" has created a folder "/merge-test-outside-groups-renamebeforesecondshare"
		When user "user0" shares folder "/merge-test-outside-groups-renamebeforesecondshare" with user "user1" using the API
		And user "user1" moves folder "/merge-test-outside-groups-renamebeforesecondshare" to "/merge-test-outside-groups-renamebeforesecondshare-renamed" using the API
		And user "user0" shares folder "/merge-test-outside-groups-renamebeforesecondshare" with group "group1" using the API
		And user "user1" gets the following properties of folder "/merge-test-outside-groups-renamebeforesecondshare-renamed" using the API
			|{http://owncloud.org/ns}permissions|
		Then the single response should contain a property "{http://owncloud.org/ns}permissions" with value "SRDNVCK"
		And as "user1" the folder "/merge-test-outside-groups-renamebeforesecondshare" should not exist

	Scenario: Emptying trashbin
		Given user "user0" has been created
		And user "user0" has deleted file "/textfile0.txt"
		When user "user0" empties the trashbin using the API
		Then the HTTP status code should be "200"

	Scenario: orphaned shares
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has created a folder "/common"
		And user "user0" has created a folder "/common/sub"
		And user "user0" has shared file "/common/sub" with user "user1"
		And user "user0" has deleted folder "/common"
		When user "user0" empties the trashbin using the API
		Then as "user1" the folder "/sub" should not exist

	Scenario: sharing again an own file while belonging to a group
		Given user "user0" has been created
		And group "sharing-group" has been created
		And user "user0" has been added to group "sharing-group"
		And user "user0" has shared file "welcome.txt" with group "sharing-group"
		And user "user0" has deleted the last share
		When user "user0" sends HTTP method "POST" to API endpoint "/apps/files_sharing/api/v1/shares" with body
			| path      | welcome.txt   |
			| shareWith | sharing-group |
			| shareType | 1             |
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"

	Scenario: sharing subfolder when parent already shared
		Given user "user0" has been created
		Given user "user1" has been created
		And group "sharing-group" has been created
		And user "user0" has created a folder "/test"
		And user "user0" has created a folder "/test/sub"
		And user "user0" has shared file "/test" with group "sharing-group"
		When user "user0" sends HTTP method "POST" to API endpoint "/apps/files_sharing/api/v1/shares" with body
			| path      | /test/sub |
			| shareWith | user1     |
			| shareType | 0         |
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And as "user1" the folder "/sub" should exist

	Scenario: sharing subfolder when parent already shared with group of sharer
		Given user "user0" has been created
		And user "user1" has been created
		And group "sharing-group" has been created
		And user "user0" has been added to group "sharing-group"
		And user "user0" has created a folder "/test"
		And user "user0" has created a folder "/test/sub"
		And user "user0" has shared file "/test" with group "sharing-group"
		When user "user0" sends HTTP method "POST" to API endpoint "/apps/files_sharing/api/v1/shares" with body
			| path      | /test/sub |
			| shareWith | user1     |
			| shareType | 0         |
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And as "user1" the folder "/sub" should exist

	Scenario: sharing subfolder of already shared folder, GET result is correct
		Given user "user0" has been created
		And user "user1" has been created
		And user "user2" has been created
		And user "user3" has been created
		And user "user4" has been created
		And user "user0" has created a folder "/folder1"
		And user "user0" has shared file "/folder1" with user "user1"
		And user "user0" has shared file "/folder1" with user "user2"
		And user "user0" has created a folder "/folder1/folder2"
		And user "user0" has shared file "/folder1/folder2" with user "user3"
		And user "user0" has shared file "/folder1/folder2" with user "user4"
		And as user "user0"
		When the user sends HTTP method "GET" to API endpoint "/apps/files_sharing/api/v1/shares"
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And the response should contain 4 entries
		And file "/folder1" should be included as path in the response
		And file "/folder1/folder2" should be included as path in the response
		And the user sends HTTP method "GET" to API endpoint "/apps/files_sharing/api/v1/shares?path=/folder1/folder2"
		And the response should contain 2 entries
		And file "/folder1" should not be included as path in the response
		And file "/folder1/folder2" should be included as path in the response

	Scenario: unshare from self
		Given user "user0" has been created
		And user "user1" has been created
		And group "sharing-group" has been created
		And user "user0" has been added to group "sharing-group"
		And user "user1" has been added to group "sharing-group"
		And user "user0" has shared file "/PARENT/parent.txt" with group "sharing-group"
		And user "user0" has stored etag of element "/PARENT"
		And user "user1" has stored etag of element "/"
		When user "user1" deletes the last share using the API
		Then the etag of element "/" of user "user1" should have changed
		And the etag of element "/PARENT" of user "user0" should not have changed

	Scenario: Increasing permissions is allowed for owner
		Given user "user0" has been created
		And user "user1" has been created
		And group "new-group" has been created
		And user "user0" has been added to group "new-group"
		And user "user1" has been added to group "new-group"
		And user "user0" has been made a subadmin of group "new-group"
		And as user "user0"
		And the user has shared folder "/FOLDER" with group "new-group"
		And the user has updated the last share with
			| permissions | 1 |
		When the user updates the last share using the API with
			| permissions | 31 |
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"

	Scenario: Cannot create share with zero permissions
		Given user "user0" has been created
		And user "user1" has been created
		When user "user0" sends HTTP method "POST" to API endpoint "/apps/files_sharing/api/v1/shares" with body
			| path        | welcome.txt |
			| shareWith   | user1       |
			| shareType   | 0           |
			| permissions | 0           |
		Then the OCS status code should be "400"

	Scenario: Cannot set permissions to zero
		Given user "user0" has been created
		And user "user1" has been created
		And group "new-group" has been created
		And user "user0" has been added to group "new-group"
		And user "user1" has been added to group "new-group"
		And user "user0" has been made a subadmin of group "new-group"
		And user "user0" has shared folder "/FOLDER" with group "new-group"
		When user "user0" updates the last share using the API with
			| permissions | 0 |
		Then the OCS status code should be "400"

	Scenario: Adding public upload to a read only shared folder as recipient is not allowed
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has created a folder "/test"
		And user "user0" has shared folder "/test" with user "user1" with permissions 17
		And as user "user1"
		And the user has created a share with settings
			| path         | /test |
			| shareType    | 3     |
			| publicUpload | false |
		When the user updates the last share using the API with
			| publicUpload | true |
		Then the OCS status code should be "404"
		And the HTTP status code should be "200"

	Scenario: Adding public upload to a shared folder as recipient is allowed with permissions
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has created a folder "/test"
		And user "user0" has shared folder "/test" with user "user1" with permissions 31
		And as user "user1"
		And the user has created a share with settings
			| path         | /test |
			| shareType    | 3     |
			| publicUpload | false |
		When the user updates the last share using the API with
			| publicUpload | true |
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"

	Scenario: Adding public upload to a read only shared folder as recipient is not allowed
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has created a folder "/test"
		And user "user0" has shared folder "/test" with user "user1" with permissions 17
		And as user "user1"
		And the user has created a share with settings
			| path        | /test |
			| shareType   | 3     |
			| permissions | 1     |
		When the user updates the last share using the API with
			| permissions | 15 |
		Then the OCS status code should be "404"
		And the HTTP status code should be "200"

	Scenario: Adding public upload to a shared folder as recipient is allowed with permissions
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has created a folder "/test"
		And user "user0" has shared folder "/test" with user "user1" with permissions 31
		And as user "user1"
		And the user has created a share with settings
			| path        | /test |
			| shareType   | 3     |
			| permissions | 1     |
		When the user updates the last share using the API with
			| permissions | 15 |
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"

	Scenario: Creating a link share with no specified permissions defaults to read permissions
		Given user "user0" has been created
		And user "user0" has created a folder "/afolder"
		When user "user0" creates a share using the API with settings
			| path      | /afolder |
			| shareType | 3        |
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And the share fields of the last share should include
			| id          | A_NUMBER |
			| share_type  | 3        |
			| permissions | 1        |

	Scenario: Creating a link share with no specified permissions defaults to read permissions when public upload disabled globally
		Given parameter "shareapi_allow_public_upload" of app "core" has been set to "no"
		And user "user0" has been created
		And user "user0" has created a folder "/afolder"
		When user "user0" creates a share using the API with settings
			| path      | /afolder |
			| shareType | 3        |
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And the share fields of the last share should include
			| id          | A_NUMBER |
			| share_type  | 3        |
			| permissions | 1        |

	Scenario: Creating a link share with edit permissions keeps it
		Given user "user0" has been created
		And user "user0" has created a folder "/afolder"
		When user "user0" creates a share using the API with settings
			| path        | /afolder |
			| shareType   | 3        |
			| permissions | 15       |
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And the share fields of the last share should include
			| id          | A_NUMBER |
			| share_type  | 3        |
			| permissions | 15       |

	Scenario: resharing using a public link with read only permissions is not allowed
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has created a folder "/test"
		And user "user0" has shared folder "/test" with user "user1" with permissions 1
		When user "user1" creates a share using the API with settings
			| path         | /test |
			| shareType    | 3     |
			| publicUpload | false |
		Then the OCS status code should be "404"
		And the HTTP status code should be "200"

	Scenario: resharing using a public link with read and write permissions only is not allowed
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has created a folder "/test"
		And user "user0" has shared folder "/test" with user "user1" with permissions 15
		When user "user1" creates a share using the API with settings
			| path         | /test |
			| shareType    | 3     |
			| publicUpload | false |
		Then the OCS status code should be "404"
		And the HTTP status code should be "200"

	Scenario: deleting a file out of a share as recipient creates a backup for the owner
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has created a folder "/shared"
		And user "user0" has moved file "/textfile0.txt" to "/shared/shared_file.txt"
		And user "user0" has shared folder "/shared" with user "user1"
		When user "user1" deletes file "/shared/shared_file.txt" using the API
		Then as "user1" the file "/shared/shared_file.txt" should not exist
		And as "user0" the file "/shared/shared_file.txt" should not exist
		And as "user0" the file "/shared_file.txt" should exist in trash
		And as "user1" the file "/shared_file.txt" should exist in trash

	Scenario: deleting a folder out of a share as recipient creates a backup for the owner
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has created a folder "/shared"
		And user "user0" has created a folder "/shared/sub"
		And user "user0" has moved file "/textfile0.txt" to "/shared/sub/shared_file.txt"
		And user "user0" has shared folder "/shared" with user "user1"
		When user "user1" deletes folder "/shared/sub" using the API
		Then as "user1" the folder "/shared/sub" should not exist
		And as "user0" the folder "/shared/sub" should not exist
		And as "user0" the folder "/sub" should exist in trash
		And as "user0" the file "/sub/shared_file.txt" should exist in trash
		And as "user1" the folder "/sub" should exist in trash
		And as "user1" the file "/sub/shared_file.txt" should exist in trash

	Scenario: moving a file into a share as recipient
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has created a folder "/shared"
		And user "user0" has shared folder "/shared" with user "user1"
		When user "user1" moves file "/textfile0.txt" to "/shared/shared_file.txt" using the API
		Then as "user1" the file "/shared/shared_file.txt" should exist
		And as "user0" the file "/shared/shared_file.txt" should exist

	Scenario: moving a file out of a share as recipient creates a backup for the owner
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has created a folder "/shared"
		And user "user0" has moved file "/textfile0.txt" to "/shared/shared_file.txt"
		And user "user0" has shared file "/shared" with user "user1"
		And user "user1" has moved folder "/shared" to "/shared_renamed"
		When user "user1" moves file "/shared_renamed/shared_file.txt" to "/taken_out.txt" using the API
		Then as "user1" the file "/taken_out.txt" should exist
		And as "user0" the file "/shared/shared_file.txt" should not exist
		And as "user0" the file "/shared_file.txt" should exist in trash

	Scenario: moving a folder out of a share as recipient creates a backup for the owner
		Given user "user0" has been created
		And user "user1" has been created
		And user "user0" has created a folder "/shared"
		And user "user0" has created a folder "/shared/sub"
		And user "user0" has moved file "/textfile0.txt" to "/shared/sub/shared_file.txt"
		And user "user0" has shared file "/shared" with user "user1"
		And user "user1" has moved folder "/shared" to "/shared_renamed"
		When user "user1" moves folder "/shared_renamed/sub" to "/taken_out" using the API
		Then as "user1" the file "/taken_out" should exist
		And as "user0" the folder "/shared/sub" should not exist
		And as "user0" the folder "/sub" should exist in trash
		And as "user0" the file "/sub/shared_file.txt" should exist in trash

	Scenario: User's own shares reshared to him don't appear when getting "shared with me" shares
		Given user "user0" has been created
		And user "user1" has been created
		And group "group0" has been created
		And user "user0" has been added to group "group0"
		And user "user0" has created a folder "/shared"
		And user "user0" has moved file "/textfile0.txt" to "/shared/shared_file.txt"
		And user "user0" has shared folder "/shared" with user "user1"
		And user "user1" has shared folder "/shared" with group "group0"
		When user "user0" sends HTTP method "GET" to API endpoint "/apps/files_sharing/api/v1/shares?shared_with_me=true"
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And the last share_id should not be included in the response

	Scenario: Share ownership change after moving a shared file outside of an outer share
		Given user "user0" has been created
		And user "user1" has been created
		And user "user2" has been created
		And user "user0" has created a folder "/folder1"
		And user "user0" has created a folder "/folder1/folder2"
		And user "user1" has created a folder "/moved-out"
		And user "user0" has shared folder "/folder1" with user "user1" with permissions 31
		And user "user1" has shared folder "/folder1/folder2" with user "user2" with permissions 31
		When user "user1" moves folder "/folder1/folder2" to "/moved-out/folder2" using the API
		And user "user1" gets the info of the last share using the API
		Then the share fields of the last share should include
			| id                | A_NUMBER             |
			| item_type         | folder               |
			| item_source       | A_NUMBER             |
			| share_type        | 0                    |
			| file_source       | A_NUMBER             |
			| file_target       | /folder2             |
			| permissions       | 31                   |
			| stime             | A_NUMBER             |
			| storage           | A_NUMBER             |
			| mail_send         | 0                    |
			| uid_owner         | user1                |
			| storage_id        | home::user1          |
			| file_parent       | A_NUMBER             |
			| displayname_owner | user1                |
			| mimetype          | httpd/unix-directory |
		And as "user0" the folder "/folder1/folder2" should not exist
		And as "user2" the folder "/folder2" should exist

	Scenario: Share ownership change after moving a shared file to another share
		Given user "user0" has been created
		And user "user1" has been created
		And user "user2" has been created
		And user "user0" has created a folder "/user0-folder"
		And user "user0" has created a folder "/user0-folder/folder2"
		And user "user2" has created a folder "/user2-folder"
		And user "user0" has shared folder "/user0-folder" with user "user1" with permissions 31
		And user "user2" has shared folder "/user2-folder" with user "user1" with permissions 31
		When user "user1" moves folder "/user0-folder/folder2" to "/user2-folder/folder2" using the API
		And user "user1" gets the info of the last share using the API
		Then the share fields of the last share should include
			| id                | A_NUMBER             |
			| item_type         | folder               |
			| item_source       | A_NUMBER             |
			| share_type        | 0                    |
			| file_source       | A_NUMBER             |
			| file_target       | /user2-folder        |
			| permissions       | 31                   |
			| stime             | A_NUMBER             |
			| storage           | A_NUMBER             |
			| mail_send         | 0                    |
			| uid_owner         | user2                |
			| file_parent       | A_NUMBER             |
			| displayname_owner | user2                |
			| mimetype          | httpd/unix-directory |
		And as "user0" the folder "/user0-folder/folder2" should not exist
		And as "user2" the folder "/user2-folder/folder2" should exist

