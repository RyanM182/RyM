## // File Downgraded and Emailed Outbound \\ ##

let starttime=90d;
let timeframe=1m;
MicrosoftPurviewInformationProtection
| where TimeGenerated > ago(starttime)
| where LabelEventType == "LabelDowngraded"
| project LabelChangeTime=TimeGenerated, UserId, ObjectId
| join kind=rightanti   (
    EmailEvents
    | where EmailDirection == "Outbound"
    | project
        TimeGenerated,
        SenderMailFromAddress,
        RecipientEmailAddress,
        EmailDirection,
        NetworkMessageId
    | join kind=inner (EmailAttachmentInfo) on NetworkMessageId
    | project
        TimeGenerated,
        SenderMailFromAddress,
        RecipientEmailAddress,
        EmailDirection,
        NetworkMessageId,
        FileName
    )
    on $left.UserId == $right.SenderMailFromAddress
| project
    TimeGenerated,
    EmailSendTime=TimeGenerated,
    SenderMailFromAddress,
    RecipientEmailAddress,
    EmailDirection,
    FileName,
    NetworkMessageId
| where (EmailSendTime - TimeGenerated) between (0min .. timeframe)
*******************************************************************************

***** v2 *****

let starttime=1d;
let timeframe=1m;
MicrosoftPurviewInformationProtection
| where TimeGenerated > ago(2d)
| where LabelEventType == "LabelDowngraded"
| extend FileName = tostring(split(ObjectId,"/")[-1])
| project LabelChangeTime=TimeGenerated, UserId, FileName
| join kind=inner (
    EmailEvents
    | where EmailDirection == "Outbound"
    | project
        TimeGenerated,
        SenderMailFromAddress,
        RecipientEmailAddress,
        EmailDirection,
        NetworkMessageId
    | join kind=inner (EmailAttachmentInfo) on NetworkMessageId
    | project
        TimeGenerated,
        SenderMailFromAddress,
        RecipientEmailAddress,
        EmailDirection,
        NetworkMessageId,
        FileName
)
on FileName
| project
    TimeGenerated,
    EmailSendTime=TimeGenerated,
    SenderMailFromAddress,
    RecipientEmailAddress,
    EmailDirection,
    FileName,
    NetworkMessageId
| where (EmailSendTime - TimeGenerated) between (0min .. timeframe)

*************************************************************************
## // EXAMPLE TWO WITH TIME SINCE EVENT AND DIFFERENT join \\ ##
let starttime=5h;
let timeframe=0m;
MicrosoftPurviewInformationProtection
| where TimeGenerated > ago(starttime)
| where LabelEventType == "LabelDowngraded"
| project
    LabelChangeTime=TimeGenerated,
    UserId,
    ObjectId,
    LabelEventType,
    SensitivityLabelId,
    OldSensitivityLabelId
	//
| join kind=rightanti   (
    EmailEvents
    | where EmailDirection == "Outbound"
    | project
        TimeGenerated,
        SenderMailFromAddress,
        RecipientEmailAddress,
        EmailDirection,
        NetworkMessageId
		//
    | join kind=inner (EmailAttachmentInfo) on NetworkMessageId
    | project
        TimeGenerated,
        SenderMailFromAddress,
        RecipientEmailAddress,
        EmailDirection,
        NetworkMessageId,
        FileName
    )
    on $left.ObjectId == $right.FileName
| project
    TimeGenerated,
    EmailSendTime=TimeGenerated,
    SenderMailFromAddress,
    RecipientEmailAddress,
    EmailDirection,
    FileName,
    NetworkMessageId
	//
| extend HowLongAgo=( now() - TimeGenerated ), TimeSinceEventHappend=( TimeGenerated - datetime(2023-02-17-1641) )
| where (EmailSendTime - TimeGenerated) between (0min .. timeframe)
| sort by TimeGenerated asc 

***************************************************************************************************************************

## // OrigianalKQL Query \\ ## 

let starttime=7d;
let timeframe=4h;
InformationProtectionEvents
| where Time > ago(starttime)
| where Activity == "DowngradeLabel"
| project LabelChangeTime=Time, User, FileName=ItemName
| join kind=inner(
    EmailEvents
    | where EmailDirection == "Outbound"
    | project
        TimeGenerated,
        SenderMailFromAddress,
        RecipientEmailAddress,
        EmailDirection,
        NetworkMessageId
    | join kind=inner (EmailAttachmentInfo) on NetworkMessageId
    | project
        TimeGenerated,
        SenderMailFromAddress,
        RecipientEmailAddress,
        EmailDirection,
        FileName
    )
    on FileName
| project
    LabelChangeTime,
    EmailSendTime=TimeGenerated,
    SenderMailFromAddress,
    RecipientEmailAddress,
    EmailDirection,
    FileName
| where (EmailSendTime - LabelChangeTime) between (0min .. timeframe)
