# ssm-unix-user-logon
#Short description
Allows AWS SSO user that has SSM access to be able to connect to an ssm compatible instance and connect to their own user profile. If there is not user profile one will be created.

When SSM Session Manager starts it creates a manifest at '/var/lib/amazon/ssm/<instanceid>/document/state/current/<sessionid>' that contains various bits of information about the session. This includes the process id of the session manager process.

The sh shell created at connection time is a child process of the session process. In any shell you can find it's parent process id using the environment variable $PPID. Using this we can iterate through the files in  '/var/lib/amazon/ssm/<instanceid>/document/state/current/' looking for the matching process id  and once found we know that is the matching sessionid.

Because the session id contains the username of the federated user we can use that to determine the active user and start a shell for that user.



#Requirements
If you want to make this seamless make sure all instances that you will connect to with Session Manager has a recent SSM Agent version. Shell profiles became available with 3.0.196.0 and the one tested here is with version 3.0.284.0. Assuming script is located at /home/ecs-user/ssmsessionlogon.sh set the Linux shell profile to:


#Use instructions
1. To use this method you first need to install jq on the instance. This is not standard on Amazon Linux. You can install it on Amazon Linux:

sudo yum install jq -y

2. The script itself can be executed by users directly after logon or can be triggered by using a shell profile configured in the Session Manager Preferences.

The session script performs the steps to get the session id and then assuming the federated usernames have the form userid@domain.com  leading to a session id such as userid@domain.com-<number/role id> this will use the @ sign to only get userid. It will then create a regular user named userid on the instance and then switch to that userid. To give this user more permissions you will have to modify the script accordingly. The script is linked in the case as ssmsessionlogon.sh and can be installed on the instances before use.

To use it assuming it is installed in /home/ec2-user/ run as follows:

sudo /home/ec2-user/ssmsessionlogon.sh $PPID

Then when a user logs on to session manager the script will run, create the user and change to that user. If the user exists it will silently fail creation but still change to that user. You can also create a custom session document if required to only use the shell profile for specific users.


3. Then go to Session Manager preferences and assuming script is located at /home/ecs-user/ssmsessionlogon.sh set the Linux shell profile to so it runs whenever an SSM user connects:

sudo /home/ec2-user/ssmsessionlogon.sh $PPID
