pageextension 78902 "Sales Prices AP" extends "Sales Prices"
{
    layout
    {
        addafter("Ending Date")
        {
            field("Reference Cost"; "Reference Cost")
            {
                ApplicationArea = All;
            }
            field("Cost Ref. Unit of Measure"; "Cost Ref. Unit of Measure")
            {
                ApplicationArea = All;
            }
            field(Description; Description)
            {
                ApplicationArea = All;
            }
            field("Description 2"; "Description 2")
            {
                ApplicationArea = All;
            }
            field("New Price Calculation"; "New Price Calculation")
            {
                ApplicationArea = All;
            }
        }
    }
}