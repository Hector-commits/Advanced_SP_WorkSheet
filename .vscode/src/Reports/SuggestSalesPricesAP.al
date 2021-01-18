report 78900 "Suggest Cust. Price Group AP"
{

    ProcessingOnly = true;

    dataset
    {
        dataitem("Customer Price Group"; "Customer Price Group")
        {
            DataItemTableView = SORTING(Code)
                                ORDER(Ascending);
            dataitem(Item; Item)
            {
                DataItemTableView = SORTING("No.");
                RequestFilterFields = "No.", "Vendor No.", "Inventory Posting Group", "Item Category Code";

                trigger OnAfterGetRecord()
                begin
                    insertSalesPriceWorkSheet();
                end;
            }

            trigger OnAfterGetRecord()
            begin
                Window.UPDATE(2, "Customer Price Group".Code);
            end;

            trigger OnPreDataItem()
            var
                populateDateError: Label 'Please populate valid dates.';
            begin
                //Checks//
                IF (purchasePriceDate = 0D) OR (openPricesDate = 0D) THEN
                    ERROR(populateDateError);

                SETFILTER(Code, CustPriceGroupFilter);

                Window.OPEN('#1#################### #2#################### #3####################');
                Window.UPDATE(1, ProcessingMessage);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(CustPriceGroupFilter; CustPriceGroupFilter)
                {
                    Caption = 'Cust. Price Group Filter';
                    Lookup = false;

                    trigger OnAssistEdit()
                    var
                        CustomerPriceGroups: Page "Customer Price Groups";
                        CustomerPriceGroup: Record "Customer Price Group";
                    begin
                        CustomerPriceGroups.LOOKUPMODE := TRUE;
                        IF CustomerPriceGroups.RUNMODAL = ACTION::LookupOK THEN BEGIN
                            CustomerPriceGroups.GETRECORD(CustomerPriceGroup);
                            CustPriceGroupFilter := CustPriceGroupFilter + CustomerPriceGroup.Code;
                        END;
                    end;
                }
                field(purchasePriceDate; purchasePriceDate)
                {
                    Caption = 'Purchase price calculation date';
                    ShowMandatory = true;
                    ToolTip = 'This is the reference data which is going to be used as a reference to find a valid purchase price.';
                }
                field(openPricesDateCtrl; openPricesDate)
                {
                    Caption = 'Prices open on date';
                    ShowMandatory = true;
                    ToolTip = 'Data used as a reference to search for open sales price at the specified date. The system will only retrieve open sales prices at the date specified.';
                }
                field(retrieveItemsWithoutSalesPrice; retrieveItemsWithoutSalesPrice)
                {
                    Caption = 'Retrieve items without sales prices';
                }
                field(replaceLines; replaceLines)
                {
                    Caption = 'Replace lines';
                    ToolTip = 'If there were previously inserted lines which match with new calculated ones, these will be removed before a new insertion. In not enabled and there are matching lines, the system will retrieve an error.';
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        Window.CLOSE;
    end;

    var
        CustPriceGroupFilter: Text[1024];
        retrieveItemsWithoutSalesPrice: Boolean;
        purchasePriceDate: Date;
        openPricesDate: Date;
        replaceLines: Boolean;
        Window: Dialog;
        ProcessingMessage: Label 'Processing...';

    local procedure insertSalesPriceWorkSheet()
    var
        SalesPrice: Record "Sales Price";
        SalesPriceWorksheet: Record "Sales Price Worksheet";
    begin
        IF replaceLines THEN
            removeOldLines;

        Window.UPDATE(3, Item."No.");

        SalesPrice.SETRANGE("Sales Type", SalesPrice."Sales Type"::"Customer Price Group");
        SalesPrice.SETRANGE("Sales Code", "Customer Price Group".Code);
        SalesPrice.SETRANGE("Item No.", Item."No.");
        IF openPricesDate <> 0D THEN
            SalesPrice.SETFILTER("Starting Date", '<=%1|%2', openPricesDate, 0D);
        IF openPricesDate <> 0D THEN
            SalesPrice.SETFILTER("Ending Date", '>=%1|%2', openPricesDate, 0D);
        IF SalesPrice.FINDSET THEN
            REPEAT
                SalesPriceWorksheet.INIT;
                SalesPriceWorksheet.VALIDATE("Item No.", SalesPrice."Item No.");
                SalesPriceWorksheet.VALIDATE("Open Prices Date", openPricesDate);
                SalesPriceWorksheet.TRANSFERFIELDS(SalesPrice);
                SalesPriceWorksheet.VALIDATE("Purchase Price Date", purchasePriceDate);//Helps to call GetPurchPrice
                SalesPriceWorksheet.VALIDATE("New Price Calculation", SalesPriceWorksheet."New Price Calculation"::"Purchase Price");
                SalesPriceWorksheet.INSERT;
            UNTIL SalesPrice.NEXT = 0
        ELSE BEGIN
            IF retrieveItemsWithoutSalesPrice THEN BEGIN
                CreateSalesPriceWorksheetLine();
            END;
        END;
    end;

    local procedure removeOldLines()
    var
        SalesPriceWorksheet: Record "Sales Price Worksheet";
    begin
        //Removes all "Customer Price Group" + "Item No." on Sales Price Worksheet lines
        SalesPriceWorksheet.RESET;
        SalesPriceWorksheet.SETRANGE("Sales Code", "Customer Price Group".Code);
        SalesPriceWorksheet.SETRANGE("Item No.", Item."No.");
        IF NOT SalesPriceWorksheet.ISEMPTY THEN
            SalesPriceWorksheet.DELETEALL;
    end;

    local procedure CreateSalesPriceWorksheetLine()
    var
        SalesPriceWorksheet: Record "Sales Price Worksheet";
        CurrItem: Record Item;
    begin
        SalesPriceWorksheet.INIT;
        SalesPriceWorksheet."Sales Type" := SalesPriceWorksheet."Sales Type"::"Customer Price Group";
        SalesPriceWorksheet."Sales Code" := "Customer Price Group".Code;
        SalesPriceWorksheet.VALIDATE("Item No.", Item."No.");
        SalesPriceWorksheet.VALIDATE("Open Prices Date", openPricesDate);
        SalesPriceWorksheet.VALIDATE("Purchase Price Date", purchasePriceDate);//Helps to call GetPurchPrice
        SalesPriceWorksheet.VALIDATE("New Price Calculation", SalesPriceWorksheet."New Price Calculation"::"Purchase Price");
        SalesPriceWorksheet.INSERT;
    end;
}

