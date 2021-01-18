tableextension 78902 "Sales Price AP" extends "Sales Price"
{
    fields
    {
        /*Watchout the field nummeration in order to keep Transferfields from Sales Price to SalesPriceWorksheet 
          if we use the same nummeration for different field definitions transferfields will crash*/
        field(78920; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(78921; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(78922; "New Price Calculation"; Option)
        {
            Caption = 'New Price Calculation';
            OptionCaption = 'Purchase Price,Unit Cost,Free';
            OptionMembers = "Purchase Price","Unit Cost",Free;
            Editable = false;
        }
        field(78923; "Reference Cost"; Decimal)
        {
            Caption = 'Reference Cost';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(78924; "Cost Ref. Unit of Measure"; Code[10])
        {
            Caption = 'Cost Ref. Unit of Measure';
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
}
