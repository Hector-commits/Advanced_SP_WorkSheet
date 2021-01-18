pageextension 78901 "Customer Price Groups AP" extends "Customer Price Groups"
{
    layout
    {
        addafter("VAT Bus. Posting Gr. (Price)")
        {
            field(Margin; Margin)
            {
                ApplicationArea = All;
            }
        }
    }
}
