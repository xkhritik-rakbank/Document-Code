import com.itextpdf.text.Chunk;
import com.itextpdf.text.Document;
import com.itextpdf.text.Element;
import com.itextpdf.text.Font;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.pdf.BaseFont;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;
 
import java.io.FileOutputStream;
import java.text.SimpleDateFormat;
import java.util.Date;
 
public class CreatePdf1 {
 
    public static void main(String[] args) {
        try {
            String templatePath = "C:/Users/g.kumar/Desktop/CustomJS/BckupFPU/iRBL.ear/iRBL.war/PDFTemplates/Pdf_Template1.pdf";
            Document document = new Document(PageSize.A4.rotate());
            PdfWriter writer = PdfWriter.getInstance(document, new FileOutputStream(templatePath));
            document.open();
 
            Font bold = new Font(Font.FontFamily.HELVETICA, 12, Font.BOLD);
            Font bold1 = new Font(Font.FontFamily.HELVETICA, 16, Font.BOLD);
 
            Date d = new Date();
            SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
            SimpleDateFormat dateFormat1 = new SimpleDateFormat("yyyy/MM/dd");
            String currentDate = dateFormat.format(d);
            String currentDate1 = dateFormat1.format(d);
            String name = "gaurav kumar";
            String num = "1234567";
 
            BaseFont arabicBaseFont = BaseFont.createFont(
                    "C:/Users/g.kumar/Desktop/CustomJS/BckupFPU/iRBL.ear/iRBL.war/PDFTemplates/arial-unicode-ms-regular/Arial Unicode MS Regular/Arial Unicode MS Regular.ttf",
                    BaseFont.IDENTITY_H, BaseFont.EMBEDDED);
            Font arabicFont = new Font(arabicBaseFont, 12);
            Font arabicFont1 = new Font(arabicBaseFont, 16);
 
            PdfPTable table = new PdfPTable(2);
            table.setWidthPercentage(100); 
            table.setWidths(new float[]{50, 50}); 
 
            PdfPCell englishCell = new PdfPCell(new Paragraph("Date: "+currentDate, bold));
            englishCell.setHorizontalAlignment(Element.ALIGN_LEFT);
            englishCell.setVerticalAlignment(Element.ALIGN_MIDDLE);
            englishCell.setBorder(PdfPCell.NO_BORDER); 
            table.addCell(englishCell);
 
            PdfPCell arabicCell = new PdfPCell(new Paragraph("التاريخ : "+ currentDate1, arabicFont));
            arabicCell.setRunDirection(PdfWriter.RUN_DIRECTION_RTL);
            arabicCell.setHorizontalAlignment(Element.ALIGN_LEFT);
            arabicCell.setVerticalAlignment(Element.ALIGN_MIDDLE);
            arabicCell.setBorder(PdfPCell.NO_BORDER); 
            table.addCell(arabicCell); 
            
            PdfPCell englishCell1 = new PdfPCell(new Paragraph(" ", bold));
            englishCell1.setHorizontalAlignment(Element.ALIGN_LEFT);
            englishCell1.setVerticalAlignment(Element.ALIGN_MIDDLE);
            englishCell1.setBorder(PdfPCell.NO_BORDER); 
            table.addCell(englishCell1);
 
            PdfPCell arabicCell1 = new PdfPCell(new Paragraph("", arabicFont));
            arabicCell1.setRunDirection(PdfWriter.RUN_DIRECTION_RTL);
            arabicCell1.setHorizontalAlignment(Element.ALIGN_LEFT);
            arabicCell1.setVerticalAlignment(Element.ALIGN_MIDDLE);
            arabicCell1.setBorder(PdfPCell.NO_BORDER);
            table.addCell(arabicCell1);
            table.addCell(englishCell1);
            table.addCell(arabicCell1);
            
            PdfPCell englishCell2 = new PdfPCell(new Paragraph("Ref. No: ", bold));
            englishCell2.setHorizontalAlignment(Element.ALIGN_LEFT);
            englishCell2.setVerticalAlignment(Element.ALIGN_MIDDLE);
            englishCell2.setBorder(PdfPCell.NO_BORDER);
            table.addCell(englishCell2);
 
            PdfPCell arabicCell2 = new PdfPCell(new Paragraph("مرجع : ", arabicFont));
            arabicCell2.setRunDirection(PdfWriter.RUN_DIRECTION_RTL);
            arabicCell2.setHorizontalAlignment(Element.ALIGN_LEFT);
            arabicCell2.setVerticalAlignment(Element.ALIGN_MIDDLE);
            arabicCell2.setBorder(PdfPCell.NO_BORDER);
            table.addCell(arabicCell2);
            table.addCell(englishCell1);
            table.addCell(arabicCell1);
            
            PdfPCell englishCell3 = new PdfPCell(new Paragraph("Respective Execution Judge", bold1));
            englishCell3.setHorizontalAlignment(Element.ALIGN_LEFT);
            englishCell3.setVerticalAlignment(Element.ALIGN_MIDDLE);
            englishCell3.setBorder(PdfPCell.NO_BORDER); 
            table.addCell(englishCell3);
 
            PdfPCell arabicCell3 = new PdfPCell(new Paragraph("اسم القاضى", arabicFont1));
            arabicCell3.setRunDirection(PdfWriter.RUN_DIRECTION_RTL);
            arabicCell3.setHorizontalAlignment(Element.ALIGN_LEFT);
            arabicCell3.setVerticalAlignment(Element.ALIGN_MIDDLE);
            arabicCell3.setBorder(PdfPCell.NO_BORDER);
            table.addCell(arabicCell3);
            
            PdfPCell englishCell4 = new PdfPCell(new Paragraph("Name of Court: Dubai Court", bold1));
            englishCell4.setHorizontalAlignment(Element.ALIGN_LEFT);
            englishCell4.setVerticalAlignment(Element.ALIGN_MIDDLE);
            englishCell4.setBorder(PdfPCell.NO_BORDER);
            table.addCell(englishCell4);
 
            PdfPCell arabicCell4 = new PdfPCell(new Paragraph("اسم المحكمة", arabicFont1));
            arabicCell4.setRunDirection(PdfWriter.RUN_DIRECTION_RTL);
            arabicCell4.setHorizontalAlignment(Element.ALIGN_LEFT);
            arabicCell4.setVerticalAlignment(Element.ALIGN_MIDDLE);
            arabicCell4.setBorder(PdfPCell.NO_BORDER);
            table.addCell(arabicCell4);
            
            PdfPCell englishCell5 = new PdfPCell(new Paragraph("P.O. Box 4700", bold1));
            englishCell5.setHorizontalAlignment(Element.ALIGN_LEFT);
            englishCell5.setVerticalAlignment(Element.ALIGN_MIDDLE);
            englishCell5.setBorder(PdfPCell.NO_BORDER); 
            table.addCell(englishCell5);
 
            PdfPCell arabicCell5 = new PdfPCell(new Paragraph("ص ب", arabicFont1));
            arabicCell5.setRunDirection(PdfWriter.RUN_DIRECTION_RTL);
            arabicCell5.setHorizontalAlignment(Element.ALIGN_LEFT);
            arabicCell5.setVerticalAlignment(Element.ALIGN_MIDDLE);
            arabicCell5.setBorder(PdfPCell.NO_BORDER);
            table.addCell(arabicCell5);
            
            PdfPCell englishCell6 = new PdfPCell(new Paragraph("Dubai, United Arab Emirates", bold1));
            englishCell6.setHorizontalAlignment(Element.ALIGN_LEFT);
            englishCell6.setVerticalAlignment(Element.ALIGN_MIDDLE);
            englishCell6.setBorder(PdfPCell.NO_BORDER);
            table.addCell(englishCell6);
 
            PdfPCell arabicCell6 = new PdfPCell(new Paragraph("____________، أ. ع.م", arabicFont1));
            arabicCell6.setRunDirection(PdfWriter.RUN_DIRECTION_RTL);
            arabicCell6.setHorizontalAlignment(Element.ALIGN_LEFT);
            arabicCell6.setVerticalAlignment(Element.ALIGN_MIDDLE);
            arabicCell6.setBorder(PdfPCell.NO_BORDER);
            table.addCell(arabicCell6);
            table.addCell(englishCell1);
            table.addCell(arabicCell1);
            table.addCell(englishCell1);
            table.addCell(arabicCell1);
            
            PdfPCell englishCell7 = new PdfPCell(new Paragraph("After Greetings,", bold1));
            englishCell7.setHorizontalAlignment(Element.ALIGN_LEFT);
            englishCell7.setVerticalAlignment(Element.ALIGN_MIDDLE);
            englishCell7.setBorder(PdfPCell.NO_BORDER); 
            table.addCell(englishCell7);
 
            PdfPCell arabicCell7 = new PdfPCell(new Paragraph("تحية طيبة وبعد", arabicFont1));
            arabicCell7.setRunDirection(PdfWriter.RUN_DIRECTION_RTL);
            arabicCell7.setHorizontalAlignment(Element.ALIGN_LEFT);
            arabicCell7.setVerticalAlignment(Element.ALIGN_MIDDLE);
            arabicCell7.setBorder(PdfPCell.NO_BORDER);
            table.addCell(arabicCell7);
            table.addCell(englishCell1);
            table.addCell(arabicCell1);
            
            PdfPCell englishCell8 = new PdfPCell(new Paragraph("With reference to your letter ref:", bold));
            englishCell8.setHorizontalAlignment(Element.ALIGN_LEFT);
            englishCell8.setVerticalAlignment(Element.ALIGN_MIDDLE);
            englishCell8.setBorder(PdfPCell.NO_BORDER);
            table.addCell(englishCell8);
 
            PdfPCell arabicCell8 = new PdfPCell(new Paragraph("ى خرؤ"+" ["+ "#Letter_RefNo#"+ "] "+"عجرم مكباطخل ةراشاب", arabicFont));
            arabicCell8.setRunDirection(PdfWriter.RUN_DIRECTION_RTL);
            arabicCell8.setHorizontalAlignment(Element.ALIGN_LEFT);
            arabicCell8.setVerticalAlignment(Element.ALIGN_MIDDLE);
            arabicCell8.setBorder(PdfPCell.NO_BORDER);
            table.addCell(arabicCell8);
            
            PdfPCell englishCell9 = new PdfPCell(new Paragraph("["+ "#Letter_RefNo#"+"] dated ["+ "#Letter_Date#"+ "] related to:", bold));
            englishCell9.setHorizontalAlignment(Element.ALIGN_LEFT);
            englishCell9.setVerticalAlignment(Element.ALIGN_MIDDLE);
            englishCell9.setBorder(PdfPCell.NO_BORDER); 
            table.addCell(englishCell9);
 
            PdfPCell arabicCell9 = new PdfPCell(new Paragraph("["+ "#Letter_Date#"+ "] " +"صوصخب"+":", arabicFont));
            arabicCell9.setRunDirection(PdfWriter.RUN_DIRECTION_RTL);
            arabicCell9.setHorizontalAlignment(Element.ALIGN_LEFT);
            arabicCell9.setVerticalAlignment(Element.ALIGN_MIDDLE);
            arabicCell9.setBorder(PdfPCell.NO_BORDER);
            table.addCell(arabicCell9);
            table.addCell(englishCell1);
            table.addCell(arabicCell1);
            
            PdfPCell englishCell10 = new PdfPCell(new Paragraph("Case Number: "+"Case123456", bold1));
            englishCell10.setHorizontalAlignment(Element.ALIGN_LEFT);
            englishCell10.setVerticalAlignment(Element.ALIGN_MIDDLE);
            englishCell10.setBorder(PdfPCell.NO_BORDER);
            table.addCell(englishCell10);
 
            PdfPCell arabicCell10 = new PdfPCell(new Paragraph("ةيضقلا مقر: "+"Case123456", arabicFont1));
            arabicCell10.setRunDirection(PdfWriter.RUN_DIRECTION_RTL);
            arabicCell10.setHorizontalAlignment(Element.ALIGN_LEFT);
            arabicCell10.setVerticalAlignment(Element.ALIGN_MIDDLE);
            arabicCell10.setBorder(PdfPCell.NO_BORDER);
            table.addCell(arabicCell10);
            table.addCell(englishCell1);
            table.addCell(arabicCell1);
            table.addCell(englishCell1);
            table.addCell(arabicCell1);
            table.addCell(englishCell1);
            table.addCell(arabicCell1);
            
            PdfPCell englishCell11 = new PdfPCell(new Paragraph("Please find below details of the banking relationship", bold));
            englishCell11.setHorizontalAlignment(Element.ALIGN_LEFT);
            englishCell11.setVerticalAlignment(Element.ALIGN_MIDDLE);
            englishCell11.setBorder(PdfPCell.NO_BORDER); 
            table.addCell(englishCell11);
 
            PdfPCell arabicCell11 = new PdfPCell(new Paragraph("(ليمعلا مسا ) ليمعلل ةيرصملا تانايبلا مكل قرن ىلي امي", arabicFont));
            arabicCell11.setRunDirection(PdfWriter.RUN_DIRECTION_RTL);
            arabicCell11.setHorizontalAlignment(Element.ALIGN_LEFT);
            arabicCell11.setVerticalAlignment(Element.ALIGN_MIDDLE);
            arabicCell11.setBorder(PdfPCell.NO_BORDER);
            table.addCell(arabicCell11);
            
            PdfPCell englishCell12 = new PdfPCell(new Paragraph("with #custName# and current balance as on", bold));
            englishCell12.setHorizontalAlignment(Element.ALIGN_LEFT);
            englishCell12.setVerticalAlignment(Element.ALIGN_MIDDLE);
            englishCell12.setBorder(PdfPCell.NO_BORDER);
            table.addCell(englishCell12);
 
            PdfPCell arabicCell12 = new PdfPCell(new Paragraph("بسح كلذو "+ currentDate+ " ى امك باسحلا ى ةروتملا ةدصرألاو", arabicFont));
            arabicCell12.setRunDirection(PdfWriter.RUN_DIRECTION_RTL);
            arabicCell12.setHorizontalAlignment(Element.ALIGN_LEFT);
            arabicCell12.setVerticalAlignment(Element.ALIGN_MIDDLE);
            arabicCell12.setBorder(PdfPCell.NO_BORDER);
            table.addCell(arabicCell12);
            
            PdfPCell englishCell13 = new PdfPCell(new Paragraph("#CurrentDate# as per Bank's records:", bold));
            englishCell13.setHorizontalAlignment(Element.ALIGN_LEFT);
            englishCell13.setVerticalAlignment(Element.ALIGN_MIDDLE);
            englishCell13.setBorder(PdfPCell.NO_BORDER); 
            table.addCell(englishCell13);
 
            PdfPCell arabicCell13 = new PdfPCell(new Paragraph("كنبلا تالجس", arabicFont));
            arabicCell13.setRunDirection(PdfWriter.RUN_DIRECTION_RTL);
            arabicCell13.setHorizontalAlignment(Element.ALIGN_LEFT);
            arabicCell13.setVerticalAlignment(Element.ALIGN_MIDDLE);
            arabicCell13.setBorder(PdfPCell.NO_BORDER);
            table.addCell(arabicCell13);
            
            document.add(table);
            document.add(new Paragraph("\n"));
 
            document.close();
 
            System.out.print("generated");
 
        } catch (Exception e) {
            System.out.print(e);
        }
    }
}