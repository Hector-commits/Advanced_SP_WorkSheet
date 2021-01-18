tableextension 78900 "Sales Price Worksheet AP" extends "Sales Price Worksheet"
{
    fields
    {
        field(78900; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            TableRelation = Vendor."No.";
        }
        field(78901; "Purchase Price Date"; Date)
        {
            Caption = 'Purchase Price Date';
        }
        field(78902; "Purchase Price"; Decimal)
        {
            Caption = 'Purchase Price';
        }
        field(78903; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
        }
        field(78904; Margin; Decimal)
        {
            Caption = '% Margin';
            MaxValue = 100;
            MinValue = 0;
        }
        field(78905; "New Price Calculation"; Option)
        {
            Caption = 'New Price Calculation';
            OptionCaption = 'Purchase Price,Unit Cost,Free';
            OptionMembers = "Purchase Price","Unit Cost",Free;
        }
        field(78906; "New Starting Date"; Date)
        {
            Caption = 'New Starting Date';
        }
        field(78907; "Purch. Unit of Measure"; Code[10])
        {
            Caption = 'Purch. Unit of Measure';
            TableRelation = IF ("Item No." = FILTER(<> '')) "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(78908; "Open Prices Date"; Date)
        {
            Caption = 'Open Prices Date';
        }
        field(78909; "Sales Price Exist"; Boolean)
        {
            CalcFormula = Exist("Sales Price" WHERE("Item No." = FIELD("Item No."),
                                                     "Sales Code" = FIELD("Sales Code"),
                                                     "Sales Type" = FIELD("Sales Type"),
                                                     "Currency Code" = FIELD("Currency Code"),
                                                     "Starting Date" = FIELD("Starting Date"),
                                                     "Minimum Quantity" = FIELD("Minimum Quantity"),
                                                     "Variant Code" = FIELD("Variant Code"),
                                                     "Unit of Measure Code" = FIELD("Unit of Measure Code"),
                                                     "Unit Price" = FIELD("Current Unit Price")));
            Caption = 'Sales Price Exist';
            Editable = false;
            FieldClass = FlowField;
        }
        field(78910; "Item Description 2"; Text[50])
        {
            CalcFormula = Lookup(Item."Description 2" WHERE("No." = FIELD("Item No.")));
            Caption = 'Item Description 2';
            FieldClass = FlowField;
        }
    }

    procedure GetPurchPrice()
    var
        tempRequisitionLine: Record "Requisition Line" temporary;
    begin
        //Use of a tempRequisitionLine as a support for calculating Direct Unit Cost with discounts
        tempRequisitionLine.INIT;
        tempRequisitionLine."Worksheet Template Name" := 'TEST';
        tempRequisitionLine."Journal Batch Name" := 'TEST';
        tempRequisitionLine."Line No." := 10000;
        tempRequisitionLine.Type := tempRequisitionLine.Type::Item;
        tempRequisitionLine."No." := Rec."Item No.";
        tempRequisitionLine."Variant Code" := Rec."Variant Code";
        IF Rec."Minimum Quantity" > 0 THEN
            tempRequisitionLine.Quantity := Rec."Minimum Quantity"
        ELSE
            tempRequisitionLine.Quantity := 1;
        tempRequisitionLine."Unit of Measure Code" := Rec."Purch. Unit of Measure";
        tempRequisitionLine."Currency Code" := Rec."Currency Code";
        tempRequisitionLine."Order Date" := Rec."Purchase Price Date";
        tempRequisitionLine.VALIDATE("Vendor No.", Rec."Vendor No.");
        IF tempRequisitionLine."Line Discount %" <> 0 THEN
            tempRequisitionLine."Direct Unit Cost" := tempRequisitionLine."Direct Unit Cost" * ((100 - tempRequisitionLine."Line Discount %") / 100);

        IF (Rec."Vendor No." = '') OR VendorPurchPriceNotExist THEN
            Rec.VALIDATE("Purchase Price", 0)
        ELSE
            Rec.VALIDATE("Purchase Price", tempRequisitionLine."Direct Unit Cost");
    end;

    local procedure VendorPurchPriceNotExist(): Boolean
    var
        PurchasePrice: Record "Purchase Price";
    begin
        PurchasePrice.SETRANGE("Item No.", Rec."Item No.");
        PurchasePrice.SETRANGE("Vendor No.", Rec."Vendor No.");
        PurchasePrice.SETFILTER("Starting Date", '<=%1|%2', Rec."Purchase Price Date", 0D);
        PurchasePrice.SETFILTER("Ending Date", '>=%1|%2', Rec."Purchase Price Date", 0D);
        PurchasePrice.SETRANGE("Currency Code", Rec."Currency Code");
        PurchasePrice.SETRANGE("Unit of Measure Code", Rec."Purch. Unit of Measure");
        PurchasePrice.SETFILTER("Minimum Quantity", '<=%1', Rec."Minimum Quantity");
        IF PurchasePrice.ISEMPTY THEN
            EXIT(TRUE)
        ELSE
            EXIT(FALSE);
    end;

}
