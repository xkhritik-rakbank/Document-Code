//mona
			
			String queryCoBorrowercustomer = "select" +" "+ Cocol_Limit_ColName +" "+"from" +" "+CoCol_GridTable+" "+ "with (nolock) where WINAME=:WI_NAME" ;
			logger.info("\nqueryExternalLimitTable:\n"+queryCoBorrowercustomer);
			params = "WI_NAME=="+winame;
			
			String inputXMLC = "<?xml version='1.0'?><APSelectWithNamedParam_Input><Option>APSelectWithNamedParam</Option><Query>" + queryCoBorrowercustomer + "</Query><Params>"+params+"</Params><EngineName>" + sCabName + "</EngineName><SessionId>" + sSessionId + "</SessionId></APSelectWithNamedParam_Input>";
			
			logger.info("\n InputXML to get external conditions-->"+inputXMLC);
			
			String outputXMLC = WFCustomCallBroker.execute(inputXMLC, sJtsIp, iJtsPort, 1)
			                    .replaceAll("AMPNDCHAR","&")
								.replaceAll("CCCOMMAAA",",")
								.replaceAll("PPPERCCCENTT","%");
			
			logger.info("\n outputXML to get external conditions-->"+outputXMLC);
			
			WFCustomXmlResponse xmlParserData=new WFCustomXmlResponse();
			logger.info("\n outputXML to get WFCustomXmlResponse WFCustomXmlResponse-->"+xmlParserData);
			xmlParserData.setXmlString((outputXMLC));
			logger.info("\n outputXML to get WFCustomXmlResponse outputXMLC-->"+xmlParserData);
			String mainCodeValue = xmlParserData.getVal("MainCode");
			logger.info("\n outputXML to get WFCustomXmlResponse mainCodeValue-->"+mainCodeValue);
			totalcocolRecord = Integer.parseInt(xmlParserData.getVal("TotalRetrieved"));
			logger.info("\n outputXML to get WFCustomXmlResponse totalcocolRecord-->"+totalcocolRecord);
			completeCoColDataArrList = new ArrayList<Map<String, String> >(totalcocolRecord);
			logger.info("check 1" +completeCoColDataArrList);
			if(mainCodeValue.equals("0") && totalcocolRecord>0)
			{
				objWorkList = xmlParserData.createList("Records","Record"); 
				for(objWorkList.reInitialize(true);objWorkList.hasMoreElements(true);objWorkList.skip(true))
				{
					logger.info("check 11");
					subXML = objWorkList.getVal("Record");
					objWFCustomXmlResponse = new WFCustomXmlResponse(subXML);
					individualCoColCellValueMap=null;
					individualCoColCellValueMap = new HashMap<String, String>();
					for(int j = 0; j < CoColGridColumn.length; ++j)
					{		
						logger.info("check 111:"+j);
						individualCoColCellValueMap.put(CoColGridColumn[j],objWFCustomXmlResponse.getVal(CoColGridColumn[j]));	
					}
					completeCoColDataArrList.add(individualCoColCellValueMap);
				}
			}
			XSSFRow coColumnRow = (XSSFRow)sheet.getRow(CocolDataRowStartNo-1);
			
			for(int i=0; i<completeCoColDataArrList.size(); i++ )
			{
				XSSFRow newCoColumnRow;
				
				if(i!=0)
				{
					sheet.shiftRows(currentColConditionRow, sheet.getLastRowNum(), 1);								
					sheet.createRow(currentColConditionRow);
					
					newCoColumnRow = (XSSFRow)sheet.getRow(currentColConditionRow);
					newCoColumnRow.copyRowFrom(coColumnRow, new CellCopyPolicy());					
					rowShifted++;					
				}
				else
				{
					newCoColumnRow = (XSSFRow)sheet.getRow(currentColConditionRow);
				}
				
				
				Iterator<Cell> cellIterator = coColumnRow.cellIterator();
				while (cellIterator.hasNext()) 
				{
					Cell iCell = cellIterator.next();
					Cell c = newCoColumnRow.getCell(iCell.getColumnIndex());
					
					String columnName = CellReference.convertNumToColString(iCell.getColumnIndex()); 
					
					if(coborrowercolumnExcelColumnMap.get(columnName)!=null)
					{
							String cellInfo1[] = null;
					logger.info("Inside if when i=0,coBorrowerNameInHeaderStartIndex: "+coBorrowerNameInHeaderStartIndex);
					cellInfo1 = splitAlphaNumeric(coBorrowerNameInHeaderStartIndex);
								
					Cell cell1=null;
					cell1 = sheet.getRow(Integer.parseInt(cellInfo1[1])).getCell(CellReference.convertColStringToIndex(cellInfo1[0]));
					logger.info("Inside if when i=0,name: "+completeCoColDataArrList.get(i).get(coborrowercolumnExcelColumnMap));
					cell1.setCellValue("SECURITY: "+completeCoColDataArrList.get(i).get(coborrowercolumnExcelColumnMap.get(columnName))+" (Co-Borrower)");
					}
					else
					{
						continue;
					}
				}
				newCoColumnRow.setHeight((short)(generalrowCount*255*1.15));
				
				currentColConditionRow++;
			}
			

