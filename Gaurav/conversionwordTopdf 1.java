import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.poi.xwpf.usermodel.XWPFParagraph;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.font.PDType0Font;

import java.io.FileInputStream;
import java.io.IOException;

public class WordToPdfConverter {
    public static void main(String[] args) {
        try (FileInputStream fis = new FileInputStream("input.docx");
             XWPFDocument document = new XWPFDocument(fis);
             PDDocument pdfDoc = new PDDocument()) {

            // Load a font that supports Arabic characters
            PDType0Font font = PDType0Font.load(pdfDoc, new FileInputStream("NotoNaskhArabic-Regular.ttf"));

            // Create a new PDF page
            PDPage page = new PDPage();
            pdfDoc.addPage(page);

            // Prepare to write content
            PDPageContentStream contentStream = new PDPageContentStream(pdfDoc, page);
            contentStream.setFont(font, 12);

            // Coordinates for text start
            float x = 50;
            float y = 750;

            // Iterate over paragraphs in the Word document
            for (int i = 0; i < document.getParagraphs().size(); i++) {
                XWPFParagraph paragraph = document.getParagraphs().get(i);
                String text = paragraph.getText();

                // Check if the text is RTL (contains Arabic characters)
                boolean isRtl = false;
                for (int j = 0; j < text.length(); j++) {
                    if (Character.UnicodeBlock.of(text.charAt(j)) == Character.UnicodeBlock.ARABIC) {
                        isRtl = true;
                        break;
                    }
                }

                if (isRtl) {
                    // Adjust the start point for RTL text
                    float textWidth = font.getStringWidth(text) / 1000 * 12;
                    contentStream.beginText();
                    contentStream.setTextMatrix(-1, 0, 0, 1, x + textWidth, y); // Flip horizontally for RTL
                } else {
                    contentStream.beginText();
                    contentStream.newLineAtOffset(x, y);
                }

                contentStream.showText(text);
                contentStream.endText();

                // Move to the next line
                y -= 15;
            }

            contentStream.close();

            // Save the PDF document
            pdfDoc.save("output.pdf");

            System.out.println("Conversion completed successfully.");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}




//-------------------------------------------------------------------------------------------------------//

import org.apache.poi.xwpf.usermodel.XWPFDocument;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.pdmodel.PDPage;
import org.apache.pdfbox.pdmodel.PDPageContentStream;
import org.apache.pdfbox.pdmodel.font.PDType1Font;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

public class WordToPdfConverter {
    public static void main(String[] args) {
        try (FileInputStream fis = new FileInputStream("input.docx");
             XWPFDocument document = new XWPFDocument(fis);
             PDDocument pdfDoc = new PDDocument()) {

            // Create a new PDF page
            PDPage page = new PDPage();
            pdfDoc.addPage(page);

            // Prepare to write content
            try (PDPageContentStream contentStream = new PDPageContentStream(pdfDoc, page)) {
                contentStream.setFont(PDType1Font.HELVETICA, 12);
                contentStream.beginText();
                contentStream.newLineAtOffset(100, 700);

                // Simple text extraction (more complex handling required for full conversion)
                document.getParagraphs().forEach(paragraph -> {
                    try {
                        contentStream.showText(paragraph.getText());
                        contentStream.newLineAtOffset(0, -15);
                    } catch (IOException e) {
                        e.printStackTrace();
                    }
                });

                contentStream.endText();
            }

            // Save the PDF document
            pdfDoc.save("output.pdf");

            System.out.println("Conversion completed successfully.");
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
