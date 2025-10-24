Update WorkOrderMolding
SET PartNumber = :PartNumber
      , MoldNumber = :MoldNumber
      , ResinPartNumber = :ResinPartNumber
      , ProcessSheetLocation = :ProcessSheetLocation
      , BOMWeight = :BOMWeight
      , Cavities =:Cavities
      , CycleTime = :CycleTime
      , ScrapRate = :ScrapRate
      , ChangeoverTime = :ChangeoverTime
Where ID = :ID

Select * from WorkOrderMolding where ID = :ID