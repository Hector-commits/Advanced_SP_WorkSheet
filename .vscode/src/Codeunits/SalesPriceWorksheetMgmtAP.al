codeunit 78900 "Sales Price Worksheet Mgmt AP"
{

    [EventSubscriber(ObjectType::Page, Page::"Sales Price Worksheet", 'OnNewRecordEvent', '', false, false)]
    local procedure P_7023_OnNewRecord(var Rec: Record "Sales Price Worksheet"; BelowxRec: Boolean; var xRec: Record "Sales Price Worksheet")
    begin
        IF Rec."Open Prices Date" <> 0D THEN
            EXIT;

        Rec.VALIDATE("Open Prices Date", WORKDATE);
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Price Worksheet", 'OnAfterValidateEvent', 'New Starting Date', false, false)]
    local procedure P_7023_OnAfterValidateNewStartingDate(var Rec: Record "Sales Price Worksheet"; var xRec: Record "Sales Price Worksheet")
    begin
        //We only want this to be executed from Page (does not apply to automatic processes)
        Rec.CALCFIELDS("Sales Price Exist");
        IF NOT Rec."Sales Price Exist" THEN
            Rec.VALIDATE("Open Prices Date", Rec."New Starting Date");
    end;

    [EventSubscriber(ObjectType::Page, Page::"Sales Price Worksheet", 'OnAfterValidateEvent', 'Starting Date', false, false)]
    local procedure P_7023_OnAfterValidateStartingDate(var Rec: Record "Sales Price Worksheet"; var xRec: Record "Sales Price Worksheet")
    begin
        //We only want this to be executed from Page (does not apply to automatic processes)
        Rec.CALCFIELDS("Sales Price Exist");
        IF NOT Rec."Sales Price Exist" THEN
            Rec.VALIDATE("Open Prices Date", Rec."Starting Date");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Price Worksheet", 'OnAfterValidateEvent', 'Currency Code', false, false)]
    local procedure T_7023_OnAfterValidateCurrencyCode(var Rec: Record "Sales Price Worksheet"; var xRec: Record "Sales Price Worksheet"; CurrFieldNo: Integer)
    begin
        Rec.GetPurchPrice();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Price Worksheet", 'OnAfterValidateEvent', 'Item No.', false, false)]
    local procedure T_7023_OnAfterValidateItem(var Rec: Record "Sales Price Worksheet"; var xRec: Record "Sales Price Worksheet"; CurrFieldNo: Integer)
    var
        Item: Record Item;
    begin
        IF Item.GET(Rec."Item No.") THEN BEGIN
            Rec.VALIDATE("Vendor No.", Item."Vendor No.");
            Rec.VALIDATE("Unit Cost", Item."Unit Cost");
            Rec.VALIDATE("Unit of Measure Code", Item."Sales Unit of Measure");
            Rec.VALIDATE("Purch. Unit of Measure", Item."Purch. Unit of Measure");
        END;

        Rec.GetPurchPrice();

        getMarginForRequisitionWorkSheet(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Price Worksheet", 'OnAfterValidateEvent', 'Margin', false, false)]
    local procedure T_7023_OnAfterValidateMargin(var Rec: Record "Sales Price Worksheet"; var xRec: Record "Sales Price Worksheet"; CurrFieldNo: Integer)
    begin
        newPriceCalculation(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Price Worksheet", 'OnAfterValidateEvent', 'Minimum Quantity', false, false)]
    local procedure T_7023_OnAfterValidateMinimumQuantity(var Rec: Record "Sales Price Worksheet"; var xRec: Record "Sales Price Worksheet"; CurrFieldNo: Integer)
    begin
        Rec.GetPurchPrice();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Price Worksheet", 'OnAfterValidateEvent', 'New Price Calculation', false, false)]
    local procedure T_7023_OnAfterValidateNewPriceCalculation(var Rec: Record "Sales Price Worksheet"; var xRec: Record "Sales Price Worksheet"; CurrFieldNo: Integer)
    begin
        getMarginForRequisitionWorkSheet(Rec);

        newPriceCalculation(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Price Worksheet", 'OnAfterValidateEvent', 'New Starting Date', false, false)]
    local procedure T_7023_OnAfterValidateNewStartingDate(var Rec: Record "Sales Price Worksheet"; var xRec: Record "Sales Price Worksheet"; CurrFieldNo: Integer)
    begin
        Rec.CALCFIELDS("Sales Price Exist");
        IF NOT Rec."Sales Price Exist" THEN
            Rec.VALIDATE("Starting Date", Rec."New Starting Date");
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Price Worksheet", 'OnAfterValidateEvent', 'New Unit Price', false, false)]
    local procedure T_7023_OnAfterValidateNewUnitPrice(var Rec: Record "Sales Price Worksheet"; var xRec: Record "Sales Price Worksheet"; CurrFieldNo: Integer)
    begin
        IF CurrFieldNo <> Rec.FIELDNO("New Unit Price") THEN
            EXIT;

        Rec.VALIDATE("New Price Calculation", Rec."New Price Calculation"::Free);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Price Worksheet", 'OnAfterValidateEvent', 'Open Prices Date', false, false)]
    local procedure T_7023_OnAfterValidateOpenPricesDate(var Rec: Record "Sales Price Worksheet"; var xRec: Record "Sales Price Worksheet"; CurrFieldNo: Integer)
    var
        pricesAlreadyExist: Boolean;
    begin
        Rec.CalcCurrentPrice(pricesAlreadyExist);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Price Worksheet", 'OnAfterValidateEvent', 'Purchase Price', false, false)]
    local procedure T_7023_OnAfterValidatePurchasePrice(var Rec: Record "Sales Price Worksheet"; var xRec: Record "Sales Price Worksheet"; CurrFieldNo: Integer)
    begin
        getMarginForRequisitionWorkSheet(Rec);

        newPriceCalculation(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Price Worksheet", 'OnAfterValidateEvent', 'Purchase Price Date', false, false)]
    local procedure T_7023_OnAfterValidatePurchasePriceDate(var Rec: Record "Sales Price Worksheet"; var xRec: Record "Sales Price Worksheet"; CurrFieldNo: Integer)
    begin
        Rec.GetPurchPrice();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Price Worksheet", 'OnAfterValidateEvent', 'Purch. Unit of Measure', false, false)]
    local procedure T_7023_OnAfterValidatePurchUnitOfMeasure(var Rec: Record "Sales Price Worksheet"; var xRec: Record "Sales Price Worksheet"; CurrFieldNo: Integer)
    begin
        Rec.GetPurchPrice();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Price Worksheet", 'OnAfterValidateEvent', 'Sales Code', false, false)]
    local procedure T_7023_OnAfterValidateSalesCode(var Rec: Record "Sales Price Worksheet"; var xRec: Record "Sales Price Worksheet"; CurrFieldNo: Integer)
    begin
        IF Rec."Item No." <> '' THEN //Avoid insertion issue when Item No. is still blank
            getMarginForRequisitionWorkSheet(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Price Worksheet", 'OnAfterValidateEvent', 'Unit Cost', false, false)]
    local procedure T_7023_OnAfterValidateUnitCost(var Rec: Record "Sales Price Worksheet"; var xRec: Record "Sales Price Worksheet"; CurrFieldNo: Integer)
    begin
        getMarginForRequisitionWorkSheet(Rec);

        newPriceCalculation(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Price Worksheet", 'OnAfterValidateEvent', 'Unit of Measure Code', false, false)]
    local procedure T_7023_OnAfterValidateUnitOfMeasureCode(var Rec: Record "Sales Price Worksheet"; var xRec: Record "Sales Price Worksheet"; CurrFieldNo: Integer)
    begin
        IF CurrFieldNo <> Rec.FIELDNO("Unit of Measure Code") THEN
            EXIT;

        IF (Rec."Purch. Unit of Measure" = '') AND (Rec."Unit of Measure Code" <> '') THEN
            Rec.VALIDATE("Purch. Unit of Measure", Rec."Unit of Measure Code")
        ELSE
            Rec.VALIDATE("Purch. Unit of Measure")
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Price Worksheet", 'OnAfterValidateEvent', 'Vendor No.', false, false)]
    local procedure T_7023_OnAfterValidateVendorNo(var Rec: Record "Sales Price Worksheet"; var xRec: Record "Sales Price Worksheet"; CurrFieldNo: Integer)
    begin
        IF CurrFieldNo <> Rec.FIELDNO("Vendor No.") THEN
            EXIT;

        IF Rec."Vendor No." = xRec."Vendor No." THEN
            EXIT;

        Rec.GetPurchPrice();

        getMarginForRequisitionWorkSheet(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Price Worksheet", 'OnCalcCurrentPriceOnAfterSetFilters', '', false, false)]
    local procedure T_7023_OnCalcCurrentPriceOnAfterSetFilters(var SalesPrice: Record "Sales Price"; SalesPriceWorksheet: Record "Sales Price Worksheet")
    begin
        IF SalesPriceWorksheet."Open Prices Date" <> 0D THEN BEGIN
            SalesPrice.SETRANGE("Starting Date");
            SalesPrice.SETFILTER("Starting Date", '<=%1|%2', SalesPriceWorksheet."Open Prices Date", 0D);
            SalesPrice.SETFILTER("Ending Date", '>=%1|%2', SalesPriceWorksheet."Open Prices Date", 0D);
        END;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Implement Price Change", 'OnAfterCopyToSalesPrice', '', false, false)]
    local procedure R_7053_OnAfterCopyToSalesPrice(var SalesPrice: Record "Sales Price"; SalesPriceWorksheet: Record "Sales Price Worksheet")
    var
        Item: Record Item;
        NewSalesPrice: Record "Sales Price";
    begin
        /*New assignmets*/
        SalesPriceWorksheet.CalcFields("Item Description", "Item Description 2");
        SalesPrice.Description := SalesPriceWorksheet."Item Description";
        SalesPrice."Description 2" := SalesPriceWorksheet."Item Description 2";
        SalesPrice."New Price Calculation" := SalesPriceWorksheet."New Price Calculation";
        case SalesPriceWorksheet."New Price Calculation" of
            SalesPriceWorksheet."New Price Calculation"::"Unit Cost":
                begin
                    SalesPrice."Reference Cost" := SalesPriceWorksheet."Unit Cost";
                    if Item.Get(SalesPriceWorksheet."Item No.") then
                        SalesPrice."Cost Ref. Unit of Measure" := Item."Base Unit of Measure";
                end;
            SalesPriceWorksheet."New Price Calculation"::"Purchase Price":
                begin
                    SalesPrice."Reference Cost" := SalesPriceWorksheet."Purchase Price";
                    SalesPrice."Cost Ref. Unit of Measure" := SalesPriceWorksheet."Purch. Unit of Measure";
                end;
            SalesPriceWorksheet."New Price Calculation"::Free:
                begin
                    SalesPrice."Reference Cost" := 0;
                    SalesPrice."Cost Ref. Unit of Measure" := '';
                end;
        end;


        IF SalesPriceWorksheet."New Starting Date" = 0D THEN
            EXIT;

        SalesPriceWorksheet.CALCFIELDS("Sales Price Exist");
        IF NOT SalesPriceWorksheet."Sales Price Exist" THEN
            EXIT;

        IF SalesPriceWorksheet."Current Unit Price" <> 0 THEN
            SalesPrice."Unit Price" := SalesPriceWorksheet."Current Unit Price";

        NewSalesPrice.INIT();
        NewSalesPrice.VALIDATE("Item No.", SalesPriceWorksheet."Item No.");
        NewSalesPrice.VALIDATE("Sales Type", SalesPriceWorksheet."Sales Type");
        NewSalesPrice.VALIDATE("Sales Code", SalesPriceWorksheet."Sales Code");
        NewSalesPrice.VALIDATE("Unit of Measure Code", SalesPriceWorksheet."Unit of Measure Code");
        NewSalesPrice.VALIDATE("Variant Code", SalesPriceWorksheet."Variant Code");
        NewSalesPrice.VALIDATE("Starting Date", SalesPriceWorksheet."New Starting Date");
        NewSalesPrice."Minimum Quantity" := SalesPriceWorksheet."Minimum Quantity";
        NewSalesPrice."Currency Code" := SalesPriceWorksheet."Currency Code";
        NewSalesPrice."Unit Price" := SalesPriceWorksheet."New Unit Price";
        NewSalesPrice."Price Includes VAT" := SalesPriceWorksheet."Price Includes VAT";
        NewSalesPrice."Allow Line Disc." := SalesPriceWorksheet."Allow Line Disc.";
        NewSalesPrice."Allow Invoice Disc." := SalesPriceWorksheet."Allow Invoice Disc.";
        NewSalesPrice."VAT Bus. Posting Gr. (Price)" := SalesPriceWorksheet."VAT Bus. Posting Gr. (Price)";
        IF NewSalesPrice."Unit Price" <> 0 THEN
            IF NOT NewSalesPrice.INSERT(TRUE) THEN
                NewSalesPrice.MODIFY(TRUE);
    end;

    local procedure getMarginForRequisitionWorkSheet(var Rec: Record "Sales Price Worksheet")
    var
        CustomerPriceGroup: Record "Customer Price Group";
        Customer: Record Customer;
        CustPriceGroupCode: Code[10];
    begin
        IF Rec."New Price Calculation" = Rec."New Price Calculation"::Free THEN BEGIN
            Rec.Margin := 0;
            EXIT;
        END;

        CustPriceGroupCode := getCustPriceGroupCode(Rec);

        IF CustPriceGroupCode = '' THEN
            EXIT;


        CustomerPriceGroup.SETRANGE(Code, CustPriceGroupCode);
        IF CustomerPriceGroup.FINDFIRST THEN
            Rec.VALIDATE(Margin, CustomerPriceGroup.Margin)
        ELSE
            Rec.Validate(Margin, 0);

    end;

    local procedure newPriceCalculation(var Rec: Record "Sales Price Worksheet")
    begin
        CASE Rec."New Price Calculation" OF
            Rec."New Price Calculation"::"Purchase Price":
                Rec.VALIDATE("New Unit Price", ROUND(getConversionFactorPuchToBase(Rec) *
                                                    getConversionFactorBaseToSales(Rec) *
                                                    Rec."Purchase Price" *
                                                    (1 + (Rec.Margin / 100)), 0.01));
            Rec."New Price Calculation"::"Unit Cost":
                Rec.VALIDATE("New Unit Price", ROUND(getConversionFactorBaseToSales(Rec) *
                                                    Rec."Unit Cost" *
                                                    (1 + (Rec.Margin / 100)), 0.01));
        END;
    end;

    local procedure getConversionFactorPuchToBase(Rec: Record "Sales Price Worksheet") convFactor: Decimal
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
        Item: Record Item;
    begin
        //Convert to UMC -> UMB
        Item.GET(Rec."Item No.");
        IF (Rec."Purch. Unit of Measure" = '') OR (Item."Base Unit of Measure" = Rec."Purch. Unit of Measure") THEN
            ItemUnitofMeasure.GET(Rec."Item No.", Item."Base Unit of Measure")
        ELSE
            ItemUnitofMeasure.GET(Rec."Item No.", Rec."Purch. Unit of Measure");

        convFactor := 1 / ItemUnitofMeasure."Qty. per Unit of Measure";

        EXIT(convFactor);
    end;

    local procedure getConversionFactorBaseToSales(Rec: Record "Sales Price Worksheet") convFactor: Decimal
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
        Item: Record Item;
    begin
        //Convert to UMB -> UMS
        Item.GET(Rec."Item No.");
        IF (Rec."Unit of Measure Code" = '') OR (Item."Base Unit of Measure" = Rec."Unit of Measure Code") THEN
            ItemUnitofMeasure.GET(Rec."Item No.", Item."Base Unit of Measure")
        ELSE
            ItemUnitofMeasure.GET(Rec."Item No.", Rec."Unit of Measure Code");

        convFactor := ItemUnitofMeasure."Qty. per Unit of Measure";

        EXIT(convFactor);
    end;

    local procedure getCustPriceGroupCode(Rec: Record "Sales Price Worksheet") CustPriceGroupCode: Code[10]
    var
        Customer: Record Customer;
    begin
        IF Rec."Sales Type" = Rec."Sales Type"::Customer THEN BEGIN
            IF Customer.GET(Rec."Sales Code") THEN
                EXIT(Customer."Customer Price Group")
            ELSE
                EXIT('');
        END;

        IF Rec."Sales Type" = Rec."Sales Type"::"Customer Price Group" THEN
            EXIT(Rec."Sales Code");


        EXIT('');
    end;
}

