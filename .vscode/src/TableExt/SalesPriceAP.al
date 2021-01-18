tableextension 78902 "Sales Price AP" extends "Sales Price"
{
    fields
    {
        field(78900; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(78901; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(78902; "New Price Calculation"; Option)
        {
            Caption = 'New Price Calculation';
            OptionCaption = 'Purchase Price,Unit Cost,Free';
            OptionMembers = "Purchase Price","Unit Cost",Free;
            Editable = false;
        }
        field(78903; "Reference Cost"; Decimal)
        {
            Caption = 'Reference Cost';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(78904; "Cost Ref. Unit of Measure"; Code[10])
        {
            Caption = 'Cost Ref. Unit of Measure';
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
}
