tableextension 78901 "Cust. Price Group AP" extends "Customer Price Group"
{
    fields
    {
        field(78900; Margin; Decimal)
        {
            Caption = 'Margin';
            DataClassification = ToBeClassified;
            MinValue = 0.0;
            MaxValue = 100.0;
        }
    }
}
