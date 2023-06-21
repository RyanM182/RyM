// File Downgraded and Emailed Outbound \\ 
// ***** v2 *****

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
